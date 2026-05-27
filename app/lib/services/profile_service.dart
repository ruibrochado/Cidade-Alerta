import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class ProfileService {
  final SupabaseClient supabase;

  ProfileService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  Future<Map<String, dynamic>> loadProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return {
        'name': 'Utilizador',
        'email': 'sem email',
        'profilePhotoUrl': null,
        'reportedIssuesCount': 0,
        'votedIssuesCount': 0,
      };
    }

    final reportedIssues = await supabase
        .from('issues')
        .select('id')
        .eq('user_id', user.id);

    final votedIssues = await supabase
        .from('issue_votes')
        .select('id')
        .eq('user_id', user.id);

    final profile = await supabase
        .from('profiles')
        .select('first_name, last_name, profile_photo')
        .eq('id', user.id)
        .maybeSingle();

    final firstName = profile?['first_name']?.toString() ?? '';
    final lastName = profile?['last_name']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();

    return {
      'name': fullName.isEmpty ? 'Utilizador' : fullName,
      'email': user.email ?? 'sem email',
      'profilePhotoUrl': profile?['profile_photo']?.toString(),
      'reportedIssuesCount': (reportedIssues as List).length,
      'votedIssuesCount': (votedIssues as List).length,
    };
  }

  Future<void> deleteAccount() async {
    await supabase.functions.invoke('delete-user');
    await supabase.auth.signOut();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final profile = await supabase
        .from('profiles')
        .select('id, role, municipality_id, municipalities(name, city)')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      return null;
    }

    return UserProfile.fromMap(profile);
  }
}
