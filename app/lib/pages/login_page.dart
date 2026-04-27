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

  // Cores da tua marca
  final Color backgroundGreen = const Color(0xFFCDE5CB);
  final Color primaryGreen = const Color(0xFF00D159); // Verde das funcionalidades

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
      setState(() {
        errorMessage = "Erro ao entrar. Verifica as tuas credenciais.";
      });
    } finally {
      if (mounted) setState(() { isLoading = false; });
    }
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
      backgroundColor: backgroundGreen,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 70),
            // --- LOGO DA APP ---
            Center(
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: backgroundGreen,
                  image: const DecorationImage(
                    image: AssetImage('assets/logo_capacete.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- CARTÃO DE LOGIN (Com margens laterais) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Sign in',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                    ),
                    const SizedBox(height: 30),

                    _buildLabel("Email"),
                    _buildTextField(emailController, false),
                    const SizedBox(height: 20),

                    _buildLabel("Password"),
                    _buildTextField(passwordController, true),

                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),

                    const SizedBox(height: 30),

                    // Botão Principal (Muito curvilíneo)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: StadiumBorder(), // Máxima curvatura lateral
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Sign in', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 15),
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        const Text('By clicking this button, you agree with our ',
                            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
                        GestureDetector(
                          onTap: () {}, // Link para Termos
                          child: Text('Terms and Conditions', style: TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- BOTÕES GOOGLE / APPLE (Curvilíneos) ---
                    Row(
                      children: [
                        Expanded(child: _buildSocialButton("Google", "G", Colors.red)),
                        const SizedBox(width: 15),
                        Expanded(child: _buildSocialButton("Apple", "", Colors.black)),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Links de rodapé
                    _buildFooterLink("Don't have an account? ", "Sign up", () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                    }),
                    const SizedBox(height: 12),
                    _buildFooterLink("Are you a municipality worker? ", "Sign in", () {}, isWorker: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40), // Espaço para mostrar o fundo verde em baixo
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 15, bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      cursorColor: Colors.black, // Cursor a preto como pediste
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F8F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Mais curvilíneo
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      ),
    );
  }

  Widget _buildSocialButton(String text, String symbol, Color color) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(30), // Super curvilíneo
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (text == "Google") ...[
            // Simulação do G colorido do Google
            const Text("G", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
          ] else ...[
            Icon(Icons.apple, color: color, size: 26),
          ],
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String plainText, String actionText, VoidCallback onTap, {bool isWorker = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(plainText, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        GestureDetector(
          onTap: onTap,
          child: Text(
              actionText,
              style: TextStyle(
                  color: isWorker ? primaryGreen : primaryGreen, // Ambos a verde como pediste
                  fontWeight: FontWeight.bold,
                  fontSize: 13
              )
          ),
        ),
      ],
    );
  }
}