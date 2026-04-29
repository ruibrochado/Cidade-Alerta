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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  // Variável para controlar se os campos estão preenchidos
  bool isFormValid = false;

  final Color topGreen = const Color(0xFFCDE5CB);
  final Color buttonGreen = const Color(0xFF16A34A);
  final Color disabledButtonColor = const Color(
    0xFFCCCCCC,
  ); // Cinza para quando está desativado
  final Color inputColor = const Color(0xFFF4F6F4);
  final Color bottomColor = const Color(0xFFF7F7F7);

  @override
  void initState() {
    super.initState();
    // Ouvintes para validar os campos em tempo real
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid =
        emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    if (isValid != isFormValid) {
      setState(() {
        isFormValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    if (!isFormValid) return; // Segurança extra

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
    } catch (_) {
      setState(() {
        errorMessage = "Erro ao entrar.";
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Métodos do Google e Apple permanecem iguais...
  Future<void> signInWithGoogle() async {
    /* ... teu código ... */
  }
  Future<void> signInWithApple() async {
    /* ... teu código ... */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: Container(color: topGreen)),
              Expanded(child: Container(color: bottomColor)),
            ],
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Image.asset(
                    'images/logo_login_page.png',
                    height: 130,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.construction,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.55),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Iniciar Sessão",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _label("Email"),
                        _input(emailController, false),
                        const SizedBox(height: 20),
                        _label("Palavra-passe"),
                        _input(passwordController, true),

                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              errorMessage,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        const SizedBox(height: 30),

                        // BOTÃO DE LOGIN COM COR DINÂMICA
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (isLoading || !isFormValid)
                                ? null
                                : signIn,
                            style: ElevatedButton.styleFrom(
                              // Se estiver preenchido fica verde, senão fica cinza
                              backgroundColor: isFormValid
                                  ? buttonGreen
                                  : disabledButtonColor,
                              // Borda igual aos fields (radius 14)
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Iniciar Sessão",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 15),
                        _terms(),
                        const SizedBox(height: 25),

                        Row(
                          children: [
                            Expanded(child: _social("Google")),
                            const SizedBox(width: 12),
                            Expanded(child: _social("Apple")),
                          ],
                        ),
                        const SizedBox(height: 30),
                        _footer("Não tens conta? ", "Criar Conta", () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignUpPage(),
                            ),
                          );
                        }),
                        const SizedBox(height: 10),
                        _footer(
                          "És trabalhador municipal? ",
                          "Iniciar Sessão",
                          () {},
                        ),
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

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, bottom: 6),
        child: Text(
          text,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ),
    );
  }

  Widget _input(TextEditingController controller, bool obscure) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), // Mantido como referência
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _social(String type) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () {
              /* login google/apple */
            },
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          // Borda mudada para 14 para condizer com os campos
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: FittedBox(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (type == "Google")
                  Image.network(
                    'https://developers.google.com/identity/images/g-logo.png',
                    height: 18,
                  )
                else
                  const Icon(Icons.apple, size: 20),
                const SizedBox(width: 8),
                Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _terms() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        const Text(
          "Ao clicar neste botão, concordas com os nossos ",
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          "Termos e Condições",
          style: TextStyle(
            fontSize: 11,
            color: buttonGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _footer(String text, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        GestureDetector(
          onTap: onTap,
          child: Text(
            action,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: buttonGreen,
            ),
          ),
        ),
      ],
    );
  }
}
