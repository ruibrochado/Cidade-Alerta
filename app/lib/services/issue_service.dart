import 'package:supabase_flutter/supabase_flutter.dart';

class IssueService {
  final supabase = Supabase.instance.client;

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

    if (title.trim().isEmpty) {
      throw Exception('Title cannot be empty');
    }

    if (description.trim().isEmpty) {
      throw Exception('Description cannot be empty');
    }

    if (category.trim().isEmpty) {
      throw Exception('Category cannot be empty');
    }

    if (latitude < -90 || latitude > 90) {
      throw Exception('Invalid latitude');
    }

    if (longitude < -180 || longitude > 180) {
      throw Exception('Invalid longitude');
    }

    try {
      await supabase.from('issues').insert({
        'user_id': user.id,
        'title': title.trim(),
        'description': description.trim(),
        'category': category.trim(),
        'latitude': latitude,
        'longitude': longitude,
      });
    } catch (e) {
      throw Exception('Error creating issue: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMyIssues() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    try {
      final data = await supabase
          .from('issues')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(data);
    } 
    catch (e) {
      throw Exception('Error fetching user issues: $e');
    }
  }
}

