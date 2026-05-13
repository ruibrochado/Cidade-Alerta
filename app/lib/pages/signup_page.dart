import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/custom_alert_card.dart';
import 'signin_page.dart';

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
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  String errorMessage = '';
  bool isFormValid = false;
  bool showErrorCard = false;
  bool showSuccessCard = false; // ✅ NOVO

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
    final isValid =
        firstNameController.text.isNotEmpty &&
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
      setState(() {
        errorMessage = "As palavras-passe não coincidem.";
        showErrorCard = true;
      });
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

      // ✅ MOSTRA CARD DE SUCESSO
      setState(() => showSuccessCard = true);
    } catch (e) {
      String message = "Erro ao criar conta.";

      final error = e.toString().toLowerCase();

      // 🔥 MELHOR DETEÇÃO
      if (error.contains("email-already-in-use") ||
          error.contains("already exists") ||
          error.contains("email exists")) {
        message = "Este email já está registado.";
      } else if (error.contains("invalid-email")) {
        message = "O email introduzido é inválido.";
      } else if (error.contains("weak-password")) {
        message = "A palavra-passe é demasiado fraca.";
      } else if (error.contains("network")) {
        message = "Sem ligação à internet.";
      } else {
        message = "Não foi possível criar a conta. Tenta novamente.";
      }

      setState(() {
        errorMessage = message;
        showErrorCard = true;
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _closeError() {
    setState(() => showErrorCard = false);
  }

  void _closeSuccess() {
    setState(() => showSuccessCard = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: Container(color: topGreen)),
              Expanded(child: Container(color: bottomColor)),
            ],
          ),

          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
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
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Criar Conta",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
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

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (isLoading || !isFormValid)
                                ? null
                                : signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFormValid
                                  ? buttonGreen
                                  : disabledButtonColor,
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
                                    "Registar",
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
                        const SizedBox(height: 20),
                        _footer("Já tens uma conta? ", "Entrar", () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),

          // 🔴 ERROR CARD
          if (showErrorCard)
            CustomAlertCard(
              icon: Icons.error_outline,
              iconColor: Colors.red,
              title: "Erro ao criar conta",
              message: "Email existente ou palavra-passe fora dos requisitos",
              primaryButtonText: "OK",
              onPrimaryPressed: _closeError,
            ),

          // 🟢 SUCCESS CARD
          if (showSuccessCard)
            CustomAlertCard(
              icon: Icons.check_circle_outline,
              iconColor: buttonGreen,
              title: "Conta criada com sucesso",
              message: "Agora já podes iniciar sessão.",
              primaryButtonText: "OK",
              onPrimaryPressed: _closeSuccess,
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
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
