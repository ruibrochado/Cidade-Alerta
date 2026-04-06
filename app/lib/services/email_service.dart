import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<dynamic> sendEmail({
    required String to,
    required String subject,
    required String html,
  }) async {
    final response = await _supabase.functions.invoke(
      'resend-email',
      body: {
        'to': to,
        'subject': subject,
        'html': html,
      },
    );

    if (response.status != 200) {
      throw Exception(
        'Function failed. Status: ${response.status}. Data: ${response.data}',
      );
    }

    return response.data;
  }
}