import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService authService = AuthService();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';
  bool isFormValid = false;

  final Color topGreen = const Color(0xFFCDE5CB);
  final Color buttonGreen = const Color(0xFF16A34A);
  final Color disabledButtonColor = const Color(0xFFCCCCCC);
  final Color inputColor = const Color(0xFFF4F6F4);
  final Color bottomColor = const Color(0xFFF7F7F7);

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_validateForm);
    lastNameController.addListener(_validateForm);
    emailController.addListener(_validateForm);
    passwordController.addListener(_validateForm);
    confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    final isValid = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
    if (isValid != isFormValid) {
      setState(() => isFormValid = isValid);
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!isFormValid) return;

    if (passwordController.text != confirmPasswordController.text) {
      setState(() => errorMessage = "As palavras-passe não coincidem.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      await authService.signUp(
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta criada com sucesso!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      setState(() => errorMessage = "Erro ao criar conta.");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.construction, size: 80, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Criar Conta",
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 25),

                        _label("Nome"),
                        _input(firstNameController, false, "Ex: João"),

                        const SizedBox(height: 15),
                        _label("Apelido"),
                        _input(lastNameController, false, "Ex: Silva"),

                        const SizedBox(height: 15),
                        _label("Email"),
                        _input(emailController, false, "exemplo@email.com"),

                        const SizedBox(height: 15),
                        _label("Palavra-Passe"),
                        _input(passwordController, true, "••••••••"),

                        const SizedBox(height: 15),
                        _label("Confirmar Palavra-Passe"),
                        _input(confirmPasswordController, true, "••••••••"),

                        if (errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(errorMessage, style: const TextStyle(color: Colors.red, fontSize: 12)),
                          ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (isLoading || !isFormValid) ? null : signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFormValid ? buttonGreen : disabledButtonColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                              "Registar",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),
                        _terms(),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(child: _social("Google")),
                            const SizedBox(width: 12),
                            Expanded(child: _social("Apple")),
                          ],
                        ),

                        const SizedBox(height: 25),
                        _footer("Já tens uma conta? ", "Entrar", () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                        }),

                        // O FOOTER QUE FALTAVA:
                        const SizedBox(height: 10),
                        _footer("És um trabalhador municipal? ", "Entrar", () {
                          // Ação para login municipal
                        }),
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
        child: Text(text, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
      ),
    );
  }

  Widget _input(TextEditingController controller, bool obscure, String hint) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      cursorColor: Colors.black,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    );
  }

  Widget _social(String type) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (type == "Google")
              Image.network('https://developers.google.com/identity/images/g-logo.png', height: 18)
            else
              const Icon(Icons.apple, size: 20),
            const SizedBox(width: 8),
            Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _terms() {
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        const Text("Ao clicar neste botão, concordas com os nossos ",
            style: TextStyle(fontSize: 11, color: Colors.grey), textAlign: TextAlign.center),
        Text("Termos e Condições",
            style: TextStyle(fontSize: 11, color: buttonGreen, fontWeight: FontWeight.w600)),
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
          child: Text(action, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: buttonGreen)),
        )
      ],
    );
  }
}