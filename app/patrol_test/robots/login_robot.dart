import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class LoginRobot {
  final PatrolIntegrationTester $;
  LoginRobot(this.$);

  Future<void> fullLogin(String email, String pass) async {
    await $(TextField).at(0).enterText(email);
    await $(TextField).at(1).enterText(pass);

    await $('Iniciar Sessão').at(1).tap();

    await Future.delayed(const Duration(seconds: 3));
    await $.pump();

    // Handles OS-level location permissions required for the map
    if (await $.platform.mobile.isPermissionDialogVisible(
      timeout: const Duration(seconds: 5),
    )) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }

    await Future.delayed(const Duration(seconds: 2));
    await $.pump();
  }
}
