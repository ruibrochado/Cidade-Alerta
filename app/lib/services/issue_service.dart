import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // NOVO IMPORT
import 'package:path_provider/path_provider.dart'; // NOVO IMPORT

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

  // --- NOVA FUNÇÃO DE UPLOAD COM COMPRESSÃO ---
  Future<String?> _uploadPhoto(String localPhotoPath, String userId) async {
    final File originalFile = File(localPhotoPath);
    if (!originalFile.existsSync()) throw Exception('Photo file does not exist.');

    // 1. Obter pasta temporária do telemóvel para guardar a versão comprimida
    final dir = await getTemporaryDirectory();
    final targetPath = path.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}_compressed.jpg');

    // 2. Comprimir a imagem brutalmente (sem perder qualidade visual no telemóvel)
    // Converte sempre para JPEG (o melhor para fotos) e reduz o peso drasticamente
    final XFile? compressedXFile = await FlutterImageCompress.compressAndGetFile(
      originalFile.absolute.path,
      targetPath,
      quality: 60, // 60% é o "sweet spot" (ponto ideal) entre qualidade e tamanho
      format: CompressFormat.jpeg,
    );

    if (compressedXFile == null) {
      throw Exception('Falha ao comprimir a imagem.');
    }

    final File fileToUpload = File(compressedXFile.path);

    // 3. Preparar o nome do ficheiro para o Supabase
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String storagePath = '$userId/$fileName';

    // 4. Fazer o upload da versão LEVE
    await supabase.storage.from('issue-images').upload(
      storagePath,
      fileToUpload,
      fileOptions: const FileOptions(upsert: false),
    );

    // 5. Apagar o ficheiro temporário para não encher o telemóvel do utilizador
    if (fileToUpload.existsSync()) {
      fileToUpload.deleteSync();
    }

    return supabase.storage.from('issue-images').getPublicUrl(storagePath);
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
      // Se houver foto, chama o nosso novo método comprimido
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
// --- FUNÇÃO COM PAGINAÇÃO E FILTRO DE TESTES ---
  Future<List<Map<String, dynamic>>> fetchIssues({int startIndex = 0, int limit = 10}) async {
    try {
      final List<dynamic> data = await supabase
          .from('issues')
          .select()
      // Filtros para esconder as denúncias de teste:
          .neq('title', 'Text Issue')
          .neq('title', 'Test Issue')
          .order('created_at', ascending: false)
      // A magia da paginação: dizemos de onde a onde queremos os dados
          .range(startIndex, startIndex + limit - 1);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error fetching issues: $e');
    }
  }
}