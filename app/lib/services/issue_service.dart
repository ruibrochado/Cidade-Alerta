import 'package:supabase_flutter/supabase_flutter.dart';

class IssueService {
  final SupabaseClient supabase;

  IssueService({SupabaseClient? client}) 
      : supabase = client ?? Supabase.instance.client;

  Future<void> createIssue({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      await supabase.from('issues').insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'category': category,
        'latitude': latitude,
        'longitude': longitude,
      });
    } 
    catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchIssues() async {
    try {
      final data = await supabase.from('issues').select().order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    }
    catch (e) {
      throw Exception('Error fetching issues: $e');
    }
  }
}
