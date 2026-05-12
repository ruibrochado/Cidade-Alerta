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
    await $(TextField).at(0).enterText(firstName);
    await $(TextField).at(1).enterText(lastName);
    await $(TextField).at(2).enterText(email);
    await $(TextField).at(3).enterText(password);
    await $(TextField).at(4).enterText(password);
  }

  Future<void> tapSubmit() async {
    // Ensuring the button is visible on smaller screens before interaction
    await $('Registar').scrollTo().tap();
    await $.pumpAndSettle();
  }
}
