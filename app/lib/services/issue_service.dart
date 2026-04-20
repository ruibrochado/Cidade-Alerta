import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class IssueService {
  final SupabaseClient supabase;

  IssueService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  // Buscar morada pelas coordenadas
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

  // Limpar ficheiros temporários antigos
  Future<void> _cleanupOldTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();
      final now = DateTime.now();

      for (var file in files) {
        if (file is File) {
          final stat = await file.stat();
          final age = now.difference(stat.modified);

          // Apagar ficheiros com mais de 1 hora
          if (age.inHours > 1 && (file.path.contains('compressed') || file.path.contains('temp'))) {
            await file.delete().catchError((e) => print('Erro ao limpar: $e'));
          }
        }
      }
    } catch (e) {
      print('Erro na limpeza de temporários: $e');
    }
  }

  // Fazer upload da foto
  Future<String?> _uploadPhoto(String localPhotoPath, String userId) async {
    // Verificar se o ficheiro existe
    if (localPhotoPath.isEmpty) {
      print('Caminho da foto vazio');
      return null;
    }

    final File originalFile = File(localPhotoPath);
    if (!await originalFile.exists()) {
      print('Ficheiro da foto não existe: $localPhotoPath');
      return null;
    }

    try {
      // Limpar ficheiros temporários antigos
      await _cleanupOldTempFiles();

      // Criar diretório temporário
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final compressedPath = path.join(tempDir.path, '$timestamp.jpg');

      // Verificar tamanho original
      final originalBytes = await originalFile.readAsBytes();
      print('Tamanho original: ${originalBytes.length ~/ 1024} KB');

      // Comprimir a imagem
      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.absolute.path,
        compressedPath,
        quality: 70,
        minWidth: 1024,
        minHeight: 1024,
      );

      if (compressedFile == null) {
        print('Falha ao comprimir, a usar original');
        compressedFile = XFile(originalFile.path);
      }

      final File fileToUpload = File(compressedFile.path);

      // Verificar tamanho após compressão
      final compressedBytes = await fileToUpload.readAsBytes();
      print('Tamanho após compressão: ${compressedBytes.length ~/ 1024} KB');

      // Nome único para o ficheiro
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
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

      // Apagar ficheiro temporário
      if (compressedFile.path != originalFile.path) {
        unawaited(fileToUpload.delete().catchError((e) => print('Erro ao apagar temp: $e')));
      }

      return supabase.storage.from('issue-images').getPublicUrl(storagePath);

    } catch (e) {
      print('Erro no upload: $e');
      return null;
    }
  }

  // Criar nova denúncia
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
      // Upload da foto se existir
      String? uploadedPhotoUrl;
      if (photoPath != null && photoPath.isNotEmpty) {
        uploadedPhotoUrl = await _uploadPhoto(photoPath, user.id);
      }

      // Buscar morada se não foi fornecida
      String? finalAddress = street;
      if (finalAddress == null || finalAddress.isEmpty) {
        finalAddress = await _getAddressFromCoords(latitude, longitude);
      }

      // Inserir no banco de dados
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

      // Chamar edge function sem esperar (background)
      unawaited(supabase.functions.invoke(
        'forward-issue-to-municipality',
        body: {'issue_id': issueId},
      ));

      return ticketNumber;

    } catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  // Buscar denúncias para o feed
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