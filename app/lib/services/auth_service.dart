import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase;

  AuthService({SupabaseClient? client})
    : supabase = client ?? Supabase.instance.client;

  Future<AuthResponse> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'first_name': firstName, 'last_name': lastName},
      );

      final user = response.user;

      if (user != null) {
        await supabase.from('profiles').upsert({
          'id': user.id,
          'first_name': firstName.trim(),
          'last_name': lastName.trim(),
          'role': 'citizen',
          'updated_at': DateTime.now().toIso8601String(),
        });
      }

      return response;
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      throw Exception('Error signing in: $e');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
    } catch (e) {
      throw Exception('Error signing in with Google: $e');
    }
  }

  Future<void> signInWithApple() async {
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );
    } catch (e) {
      throw Exception('Error signing in with Apple: $e');
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
