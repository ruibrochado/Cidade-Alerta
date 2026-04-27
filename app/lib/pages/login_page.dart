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

  // Cores baseadas na tua imagem
  final Color primaryGreen = const Color(0xFFCDE5CB); // Fundo menta
  final Color buttonGreen = const Color(0xFF96B794);  // Verde do botão

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
      backgroundColor: primaryGreen, // Fundo verde claro da parte de cima
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),
            // --- LOGO (Capacete + Pin) ---
            Center(
              child: Container(
                height: 120,
                width: 120,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    // Se tiveres o asset do capacete, muda aqui.
                    // Usei um icon para não dar erro de imagem em falta.
                    image: AssetImage('images/logo_app.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                child: reportImagePlaceholder(), // Placeholder caso não tenhas a imagem
              ),
            ),
            const SizedBox(height: 30),

            // --- CARTÃO BRANCO ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                  ),
                  const SizedBox(height: 30),

                  // Campo Email
                  _buildLabel("Email"),
                  _buildTextField(emailController, false),
                  const SizedBox(height: 20),

                  // Campo Password
                  _buildLabel("Password"),
                  _buildTextField(passwordController, true),

                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 13)),
                    ),

                  const SizedBox(height: 30),

                  // Botão Sign In
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Sign in', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 15),
                  const Text(
                    'By clicking this button, you agree with our Terms and Conditions',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 30),

                  // --- BOTÕES GOOGLE / APPLE ---
                  Row(
                    children: [
                      Expanded(child: _buildSocialButton("Google", Icons.g_mobiledata, Colors.red)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildSocialButton("Apple", Icons.apple, Colors.black)),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Links de rodapé
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                        child: Text("Sign up", style: TextStyle(color: buttonGreen, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Are you a municipality worker? ", style: TextStyle(color: Colors.grey)),
                      Text("Sign in", style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para os labels (Email / Password)
  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10, bottom: 5),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
    );
  }

  // Widget para os inputs arredondados e cinzentos
  Widget _buildTextField(TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF3F6F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
    );
  }

  // Widget para os botões de Social Login (Google/Apple)
  Widget _buildSocialButton(String text, IconData icon, Color iconColor) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // Apenas um placeholder caso não tenhas o ficheiro da imagem do capacete ainda
  Widget reportImagePlaceholder() {
    return const Icon(Icons.construction, size: 80, color: Color(0xFF5A7A58));
  }
}