import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = '';
  bool isLoading = false;

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await authService.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      debugPrint('ERROR: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void goToSignUpPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignUpPage()),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            const SizedBox(height: 10),
            isLoading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                        onPressed: signIn,
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Ainda não tens uma conta?'),
                          TextButton(
                            onPressed: goToSignUpPage,
                            child: const Text('Clica aqui'),
                          ),
                        ],
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}