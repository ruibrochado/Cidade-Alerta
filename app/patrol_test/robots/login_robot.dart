import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class LoginRobot {
  final PatrolIntegrationTester $;
  LoginRobot(this.$);

  Future<void> fullLogin(String email, String pass) async {
    await $(TextField).at(0).enterText(email);
    await $(TextField).at(1).enterText(pass);
    await $('Sign in').at(1).tap();

    // Dá tempo para o Supabase responder
    await Future.delayed(const Duration(seconds: 3));
    await $.pump();

    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }

    // Espera que a animação de navegação para a Home termine (sem encravar)
    await Future.delayed(const Duration(seconds: 2));
    await $.pump();
  }
}