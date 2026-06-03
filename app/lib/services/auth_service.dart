import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';

class AuthService {
  final SupabaseClient supabase;
  final NotificationService notificationService;

  AuthService({
    SupabaseClient? client,
    NotificationService? notificationService,
  }) : supabase = client ?? Supabase.instance.client,
       notificationService = notificationService ?? NotificationService();

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

        try {
          await notificationService.initialize();
        } catch (e) {
          // Non-fatal: signup should not fail because of notifications.
        }
      }

      return response;
    } catch (e) {
      throw Exception('Error signing up: $e');
    }
  }

  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        try {
          await notificationService.initialize();
        } catch (e) {
          // Non-fatal: login should not fail because of notifications.
        }
      }

      return response;
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
    try {
      await notificationService.clearFcmToken();
    } catch (e) {
      // Non-fatal: logout should continue even if token clearing fails.
    }

    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }
}
