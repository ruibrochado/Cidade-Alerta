import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class RegisterRobot {
  final PatrolIntegrationTester $;
  RegisterRobot(this.$);

  Future<void> fillRegistrationForm({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    // Entering text in the 4 fields by order (Nome, Apelido, Email, Password)
    await $(TextField).at(0).enterText(firstName);
    await $(TextField).at(1).enterText(lastName);
    await $(TextField).at(2).enterText(email);
    await $(TextField).at(3).enterText(password);
  }

  Future<void> tapSubmit() async {
    // Matches the button in the screenshot
    await $('Criar Conta').tap();
    await $.pumpAndSettle();
  }
}
