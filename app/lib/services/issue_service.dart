import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class IssueService {
  final SupabaseClient supabase;
  static const int pageSize = 4;

  IssueService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  Future<String?> _getAddressFromCoords(double lat, double lng) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        lng,
      );

      if (placemarks.isEmpty) return null;

      final Placemark place = placemarks.first;

      final addressParts = [
        place.street,
        place.locality,
      ].where((part) => part != null && part.trim().isNotEmpty).toList();

      if (addressParts.isEmpty) return null;

      return addressParts.join(', ');
    } catch (_) {
      return null;
    }
  }

  Future<String?> _uploadPhoto(String localPhotoPath, String userId) async {
    final File file = File(localPhotoPath);

    if (!file.existsSync()) {
      throw Exception('Photo file does not exist.');
    }

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
    String? street,
    String? photoPath,
  }) async {
    final User? user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      String? uploadedPhotoUrl;

      if (photoPath != null && photoPath.isNotEmpty) {
        uploadedPhotoUrl = await _uploadPhoto(photoPath, user.id);
      }

      String? finalAddress = street?.trim();

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
          .order('score', ascending: false)
          .order('created_at', ascending: false)
          .range(from, to);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw Exception('Error fetching issues: $e');
    }
  }

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
          ''')
          .eq('issue_id', issueId)
          .order('created_at', ascending: true);

      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Erro a buscar comentários: $e');
      return [];
    }
  }

  Future<void> addComment(String issueId, String content) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

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

  Future<Map<String, dynamic>> fetchVoteInfo(String issueId) async {
    final user = supabase.auth.currentUser;

    try {
      final issueResponse = await supabase
          .from('issues')
          .select('score')
          .eq('id', issueId)
          .maybeSingle();

      final int score = (issueResponse?['score'] as int?) ?? 0;

      int userVote = 0;

      if (user != null) {
        final voteResponse = await supabase
            .from('issue_votes')
            .select('vote_type')
            .eq('issue_id', issueId)
            .eq('user_id', user.id)
            .maybeSingle();

        if (voteResponse != null) {
          userVote = (voteResponse['vote_type'] as int?) ?? 0;
        }
      }

      return {'score': score, 'userVote': userVote};
    } catch (e) {
      debugPrint('Erro a buscar votos: $e');

      return {'score': 0, 'userVote': 0};
    }
  }

  Future<void> castVote(String issueId, int voteType) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final existingVote = await supabase
          .from('issue_votes')
          .select()
          .eq('issue_id', issueId)
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingVote != null) {
        if (existingVote['vote_type'] == voteType) {
          await supabase
              .from('issue_votes')
              .delete()
              .eq('id', existingVote['id']);
        } else {
          await supabase
              .from('issue_votes')
              .update({'vote_type': voteType})
              .eq('id', existingVote['id']);
        }
      } else {
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
