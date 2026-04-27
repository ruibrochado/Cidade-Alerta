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

  // Cores da marca
  final Color backgroundGreen = const Color(0xFFCDE5CB);
  final Color primaryGreen = const Color(0xFF00D159);
  // Cor para o fundo de baixo (um branco levemente cinza para destacar o card que é branco puro)
  final Color bottomBackground = const Color(0xFFF0F2F0);

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
      // O segredo do fundo bicolor: Stack com dois containers
      body: Stack(
        children: [
          // Metade de cima verde
          Container(color: backgroundGreen),
          // Metade de baixo branca/cinza
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              color: bottomBackground,
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                // --- LOGO DA APP ---
                Center(
                  child: Image.asset(
                    'assets/images/logo_app.png', // Verifica se o caminho no pubspec está 'assets/images/'
                    height: 120,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.construction, size: 100, color: Colors.black45),
                  ),
                ),
                const SizedBox(height: 40),

                // --- CARTÃO DE LOGIN ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
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

                        // Botão Sign In (Stadium)
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: const StadiumBorder(),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text('Sign in', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 15),
                        _buildTermsAndConditions(),

                        const SizedBox(height: 30),

                        // --- BOTÕES GOOGLE / APPLE ---
                        Row(
                          children: [
                            Expanded(child: _buildSocialButton("Google")),
                            const SizedBox(width: 15),
                            Expanded(child: _buildSocialButton("Apple")),
                          ],
                        ),

                        const SizedBox(height: 40),

                        _buildFooterLink("Don't have an account? ", "Sign up", () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage()));
                        }),
                        const SizedBox(height: 12),
                        _buildFooterLink("Are you a municipality worker? ", "Sign in", () {}),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 10, bottom: 8),
      child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField(TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF5F8F5),
        // Border mais arredondado para estilo "pílula"
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      ),
    );
  }

  Widget _buildSocialButton(String type) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (type == "Google")
          // Usando uma imagem para o logo oficial do Google
            Image.network(
              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_\"G\"_logo.svg/1200px-Google_\"G\"_logo.svg.png',
              height: 20,
            )
          else
            const Icon(Icons.apple, color: Colors.black, size: 24),
          const SizedBox(width: 10),
          Text(type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        const Text('By clicking this button, you agree with our ',
            style: TextStyle(color: Colors.grey, fontSize: 11)),
        GestureDetector(
          onTap: () {},
          child: Text('Terms and Conditions',
              style: TextStyle(color: primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildFooterLink(String plainText, String actionText, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(plainText, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        GestureDetector(
          onTap: onTap,
          child: Text(actionText,
              style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}