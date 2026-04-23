import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class LoginRobot {
  final PatrolIntegrationTester $; // Atualizado aqui
  LoginRobot(this.$);

  Future<void> fullLogin(String email, String pass) async {
    await $(TextField).at(0).enterText(email);
    await $(TextField).at(1).enterText(pass);
    await $('Login').tap();

    // ignore: deprecated_member_use
    if (await $.native.isPermissionDialogVisible()) {
      // ignore: deprecated_member_use
      await $.native.grantPermissionWhenInUse();
    }
    await $.pumpAndSettle();
  }
}
