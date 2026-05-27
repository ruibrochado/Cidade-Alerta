import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'home_page.dart';
import 'municipality_dashboard_page.dart';
import 'signin_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthService authService = AuthService();
  final ProfileService profileService = ProfileService();

  late final Future<Widget> _initialPageFuture = _resolveInitialPage();

  Future<Widget> _resolveInitialPage() async {
    final user = authService.getCurrentUser();

    if (user == null) {
      return const LoginPage();
    }

    final profile = await profileService.getCurrentUserProfile();

    if (profile == null) {
      await authService.signOut();
      return const LoginPage();
    }

    if (profile.isMunicipalityWorker) {
      return const MunicipalityDashboardPage();
    }

    return const HomePage();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _initialPageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF16A34A)),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar sessão. Tenta iniciar sessão novamente.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return snapshot.data ?? const LoginPage();
      },
    );
  }
}
