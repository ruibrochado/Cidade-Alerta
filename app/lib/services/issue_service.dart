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

  // --- FUNÇÃO DE UPLOAD CORRIGIDA ---
  Future<String?> _uploadPhoto(String localPhotoPath, String userId) async {
    final File originalFile = File(localPhotoPath);
    if (!originalFile.existsSync()) throw Exception('Photo file does not exist.');

    // 1. IMPORTANTE: Pequena pausa para o Android libertar o hardware da câmara da RAM
    await Future.delayed(const Duration(milliseconds: 500));

    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg');

    try {
      // 2. Comprime com limites de largura/altura (minWidth/minHeight)
      // Isto evita que o plugin tente carregar 108MP de uma vez na memória
      final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
        originalFile.path, // Usamos path direto para evitar bugs de conversão
        targetPath,
        quality: 50,      // Qualidade ligeiramente mais baixa para garantir estabilidade
        minWidth: 1280,   // Força redimensionamento para HD
        minHeight: 720,   // Evita crashes de OutOfMemory (OOM)
        format: CompressFormat.jpeg,
      );

      if (compressedXFile == null) {
        throw Exception('Falha ao comprimir a imagem.');
      }

      final File fileToUpload = File(compressedXFile.path);
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String storagePath = '$userId/$fileName';

      // 3. Upload para o Supabase
      await supabase.storage.from('issue-images').upload(
        storagePath,
        fileToUpload,
        fileOptions: const FileOptions(upsert: false),
      );

      // 4. Limpeza de ficheiros temporários
      if (fileToUpload.existsSync()) {
        fileToUpload.deleteSync();
      }

      return supabase.storage.from('issue-images').getPublicUrl(storagePath);
    } catch (e) {
      print("Erro crítico na compressão: $e");
      // Tenta fazer o upload sem compressão se a compressão falhar, ou retorna null
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

      await supabase.functions.invoke(
        'forward-issue-to-municipality',
        body: {'issue_id': issueId},
      );

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