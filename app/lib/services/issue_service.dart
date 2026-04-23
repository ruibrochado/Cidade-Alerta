import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class IssueService {
  final SupabaseClient supabase;
  static const int pageSize = 4;

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
      debugPrint("Erro no geocoding: $e");
    }
    return null;
  }

  Future<String?> _uploadPhoto(String localPhotoPath, String userId) async {
    final File file = File(localPhotoPath);
    if (!file.existsSync()) throw Exception('Photo file does not exist.');

    final String fileExtension = path.extension(localPhotoPath).toLowerCase();
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
    final String storagePath = '$userId/$fileName';

    await supabase.storage
        .from('issue-images')
        .upload(
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
    String? street, // VOLTEI A ADICIONAR ESTE PARÂMETRO
    String? photoPath,
  }) async {
    final User? user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      String? uploadedPhotoUrl;
      if (photoPath != null && photoPath.isNotEmpty) {
        uploadedPhotoUrl = await _uploadPhoto(photoPath, user.id);
      }

      // Se a rua não vier preenchida do ecrã anterior, tentamos obter aqui
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
            'address':
                finalAddress, // Usa a rua final (ou a passada ou a detectada)
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

  Future<int> fetchIssuesCount() async {
    final response = await supabase
        .from('issues')
        .select('id')
        .neq('title', 'Test issue')
        .count(CountOption.exact);
    return response.count;
  }

  Future<List<Map<String, dynamic>>> fetchIssues({int page = 0}) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      final List<dynamic> data = await supabase
          .from('issues')
          .select()
          .neq('title', 'Test issue')
          .order('created_at', ascending: false)
          .range(from, to);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error fetching issues: $e');
    }
  }

  // ==========================================
  // NOVOS MÉTODOS PARA OS COMENTÁRIOS
  // ==========================================

  // Vai buscar todos os comentários de uma denúncia específica
  Future<List<Map<String, dynamic>>> fetchComments(String issueId) async {
    try {
      final data = await supabase
          .from('comments')
          .select('''
            *,
            profiles:user_id (
              first_name,
              last_name
            )
          ''') // Pede os dois campos à tabela profiles
          .eq('issue_id', issueId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Erro a buscar comentários: $e');
      return [];
    }
  }

  // Adiciona um novo comentário à base de dados
  Future<void> addComment(String issueId, String content) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await supabase.from('comments').insert({
        'issue_id': issueId,
        'user_id': user.id,
        'content': content,
      });
    } catch (e) {
      throw Exception('Erro ao adicionar comentário: $e');
    }
  }

  // Vai buscar a pontuação total (upvotes - downvotes) e o voto do user atual
  Future<Map<String, dynamic>> fetchVoteInfo(String issueId) async {
    final user = supabase.auth.currentUser;

    try {
      final response = await supabase
          .from('issue_votes')
          .select('vote_type, user_id')
          .eq('issue_id', issueId);

      int score = 0;
      int userVote = 0;

      for (var row in response) {
        int vote = row['vote_type'] as int;
        score += vote;
        if (user != null && row['user_id'] == user.id) {
          userVote = vote;
        }
      }

      return {'score': score, 'userVote': userVote};
    } catch (e) {
      debugPrint('Erro a buscar votos: $e');
      return {'score': 0, 'userVote': 0};
    }
  }

  // Regista, atualiza ou remove um voto
  Future<void> castVote(String issueId, int voteType) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      // Verifica se o user já votou nesta issue
      final existingVote = await supabase
          .from('issue_votes')
          .select()
          .eq('issue_id', issueId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingVote != null) {
        if (existingVote['vote_type'] == voteType) {
          // Se clicar no mesmo botão, remove o voto (toggle)
          await supabase
              .from('issue_votes')
              .delete()
              .eq('id', existingVote['id']);
        } else {
          // Muda de upvote para downvote ou vice-versa
          await supabase
              .from('issue_votes')
              .update({'vote_type': voteType})
              .eq('id', existingVote['id']);
        }
      } else {
        // Insere um voto novo
        await supabase.from('issue_votes').insert({
          'issue_id': issueId,
          'user_id': user.id,
          'vote_type': voteType,
        });
      }
    } catch (e) {
      throw Exception('Erro ao registar voto: $e');
    }
  }
}
