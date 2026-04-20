import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class IssueService {
  final SupabaseClient supabase;

  IssueService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  Future<String?> _getAddressFromCoords(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final Placemark pos = placemarks[0];
        return "${pos.street}, ${pos.locality}";
      }
    } catch (e) {
      print("Erro no geocoding: $e");
    }
    return null;
  }

  // --- FUNÇÃO DE UPLOOT CORRIGIDA E MAIS SEGURA ---
  Future<String?> _uploadPhoto(String localPhotoPath, String userId) async {
    // Verificação inicial
    if (localPhotoPath.isEmpty) {
      throw Exception('Caminho da foto vazio');
    }

    final File originalFile = File(localPhotoPath);
    if (!await originalFile.exists()) {
      throw Exception('Ficheiro da foto não existe: $localPhotoPath');
    }

    try {
      // Criar diretório temporário se não existir
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedPath = path.join(tempDir.path, '$timestamp.jpg');

      // Ler o ficheiro original primeiro para verificar tamanho
      final originalBytes = await originalFile.readAsBytes();
      print('Tamanho original: ${originalBytes.length ~/ 1024} KB');

      // Comprimir a imagem com parâmetros mais conservadores
      XFile? compressedFile;

      try {
        compressedFile = await FlutterImageCompress.compressAndGetFile(
          originalFile.absolute.path,
          compressedPath,
          quality: 70,  // Qualidade um pouco mais alta para manter detalhe
          minWidth: 1024,  // Largura máxima reduzida
          minHeight: 1024,  // Altura máxima reduzida
          rotate: 0,
        );
      } catch (compressError) {
        print('Erro na compressão: $compressError');
        // Fallback: usar o ficheiro original se a compressão falhar
        compressedFile = XFile(originalFile.path);
      }

      if (compressedFile == null) {
        throw Exception('Falha ao comprimir a imagem');
      }

      final File fileToUpload = File(compressedFile.path);

      // Verificar tamanho após compressão
      final compressedBytes = await fileToUpload.readAsBytes();
      print('Tamanho após compressão: ${compressedBytes.length ~/ 1024} KB');

      // Gerar nome único para o ficheiro
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final storagePath = '$userId/$fileName';

      // Upload para o Supabase
      await supabase.storage.from('issue-images').upload(
        storagePath,
        fileToUpload,
        fileOptions: const FileOptions(
          upsert: false,
          contentType: 'image/jpeg',
        ),
      );

      // Limpeza: apagar ficheiro temporário se for diferente do original
      if (compressedFile.path != originalFile.path && await fileToUpload.exists()) {
        try {
          await fileToUpload.delete();
        } catch (e) {
          print('Erro ao apagar ficheiro temporário: $e');
        }
      }

      return supabase.storage.from('issue-images').getPublicUrl(storagePath);

    } catch (e) {
      print('Erro crítico no upload: $e');
      return null;
    }
  }

  Future<String> createIssue({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    String? street,
    String? photoPath,
  }) async {
    final User? user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      String? uploadedPhotoUrl;
      if (photoPath != null && photoPath.isNotEmpty) {
        uploadedPhotoUrl = await _uploadPhoto(photoPath, user.id);
      }

      String? finalAddress = street;
      if (finalAddress == null || finalAddress.isEmpty) {
        finalAddress = await _getAddressFromCoords(latitude, longitude);
      }

      final Map<String, dynamic> insertedIssue = await supabase
          .from('issues')
          .insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'address': finalAddress,
        'photo_url': uploadedPhotoUrl,
      })
          .select('id, ticket_number')
          .single();

      final String issueId = insertedIssue['id'] as String;
      final String? ticketNumber = insertedIssue['ticket_number'] as String?;

      if (ticketNumber == null || ticketNumber.isEmpty) {
        throw Exception('Ticket number was not generated.');
      }

      // Chamar edge function em background (não esperar resposta)
      unawaited(supabase.functions.invoke(
        'forward-issue-to-municipality',
        body: {'issue_id': issueId},
      ));

      return ticketNumber;
    } catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchIssues({
    int startIndex = 0,
    int limit = 4,
    bool fetchTestsOnly = false,
  }) async {
    try {
      var query = supabase.from('issues').select();

      if (fetchTestsOnly) {
        query = query.or('title.eq.test,title.eq.Test issue,title.eq.Test Issue,title.eq.Text Issue');
      } else {
        query = query
            .neq('title', 'test')
            .neq('title', 'Test issue')
            .neq('title', 'Test Issue')
            .neq('title', 'Text Issue');
      }

      final List<dynamic> data = await query
          .order('created_at', ascending: false)
          .range(startIndex, startIndex + limit - 1);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error fetching issues: $e');
    }
  }
}