import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart'; // Já tens o import, top!

class IssueService {
  final SupabaseClient supabase;

  IssueService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  // Função interna para converter coordenadas em nome de rua
  Future<String?> _getAddressFromCoords(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final Placemark pos = placemarks[0];
        // Formato: Nome da Rua, Localidade
        return "${pos.street}, ${pos.locality}";
      }
    } catch (e) {
      print("Erro no geocoding: $e");
    }
    return null;
  }

  Future<String?> _uploadPhoto(String localPhotoPath, String userId) async {
    final File file = File(localPhotoPath);
    if (!file.existsSync()) throw Exception('Photo file does not exist.');

    final String fileExtension = path.extension(localPhotoPath).toLowerCase();
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    final String storagePath = '$userId/$fileName';

    await supabase.storage.from('issue-images').upload(
      storagePath,
      file,
      fileOptions: const FileOptions(upsert: false),
    );

    return supabase.storage.from('issue-images').getPublicUrl(storagePath);
  }

  Future<String> createIssue({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    String? photoPath,
  }) async {
    final User? user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      String? uploadedPhotoUrl;

      // 1. Faz o upload da foto se existir
      if (photoPath != null && photoPath.isNotEmpty) {
        uploadedPhotoUrl = await _uploadPhoto(photoPath, user.id);
      }

      // 2. TENTA OBTER A RUA AUTOMATICAMENTE AQUI
      // Se o geocoding falhar, ele envia null e a DB lida com isso
      String? detectedAddress = await _getAddressFromCoords(latitude, longitude);

      // 3. Faz o insert na base de dados
      final Map<String, dynamic> insertedIssue = await supabase
          .from('issues')
          .insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
        'address': detectedAddress, // <--- A MAGIA ESTÁ AQUI
        'photo_url': uploadedPhotoUrl,
      })
          .select('id, ticket_number')
          .single();

      final String issueId = insertedIssue['id'] as String;
      final String? ticketNumber = insertedIssue['ticket_number'] as String?;

      if (ticketNumber == null || ticketNumber.isEmpty) {
        throw Exception('Ticket number was not generated.');
      }

      // 4. Chama a Edge Function
      final FunctionResponse response = await supabase.functions.invoke(
        'forward-issue-to-municipality',
        body: {'issue_id': issueId},
      );

      if (response.status != 200) {
        print('Aviso: Email não enviado, mas denúncia criada.');
      }

      return ticketNumber;
    } catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchIssues() async {
    try {
      final List<dynamic> data = await supabase
          .from('issues')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error fetching issues: $e');
    }
  }
}