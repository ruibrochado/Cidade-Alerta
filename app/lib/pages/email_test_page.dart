import 'package:flutter/material.dart';
import '../services/email_service.dart';

class EmailTestPage extends StatefulWidget {
  const EmailTestPage({super.key});

  @override
  State<EmailTestPage> createState() => _EmailTestPageState();
}

class _EmailTestPageState extends State<EmailTestPage> {
  final EmailService _emailService = EmailService();

  bool _isSending = false;
  String _message = '';

  Future<void> _sendTestEmail() async {
    setState(() {
      _isSending = true;
      _message = '';
    });

    try {
      final result = await _emailService.sendEmail(
        to: 'fcprodrigomora67@gmail.com',
        subject: 'Test email from Cidade Alerta',
        html: '''
          <h1>Test email</h1>
          <p>If you received this, Resend + Supabase Edge Function is working.</p>
        ''',
      );

      setState(() {
        _message = 'Success: $result';
      });
    } catch (error) {
      setState(() {
        _message = 'Error: $error';
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Test')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _isSending ? null : _sendTestEmail,
              child: _isSending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send test email'),
            ),
            const SizedBox(height: 16),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
