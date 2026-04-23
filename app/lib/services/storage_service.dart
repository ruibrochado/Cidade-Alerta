import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase;

  StorageService({SupabaseClient? client})
      : supabase = client ?? Supabase.instance.client;

  Future<String> uploadIssueImage(File file, String fileName) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception('User not logged in');
      }

      final path = '${user.id}/$fileName';

      await supabase.storage.from('issue-images').upload(path, file);

      return path;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  String getPublicUrl(String path) {
    return supabase.storage.from('issue-images').getPublicUrl(path);
  }
}