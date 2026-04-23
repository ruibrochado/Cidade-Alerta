import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class AuthRobot {
  final PatrolIntegrationTester $;
  AuthRobot(this.$);

  Future<void> login(String email, String password) async {
    await $(TextField).at(0).enterText(email);
    await $(TextField).at(1).enterText(password);

    await $('Login').tap();
    await $.pumpAndSettle();
  }

  Future<void> goToSignUp() async {
    await $('Clica aqui').tap();
    await $.pumpAndSettle();
  }

  Future<void> signUp(String nome, String apelido, String email, String password) async {
    await $(TextField).at(0).enterText(nome);
    await $(TextField).at(1).enterText(apelido);
    await $(TextField).at(2).enterText(email);
    await $(TextField).at(3).enterText(password);

    await $.tester.testTextInput.receiveAction(TextInputAction.done);

    await $('Criar Conta').tap();
    await $.pumpAndSettle();

    await $('Account created successfully. Please login.').waitUntilVisible();
  }

  Future<void> logout() async {
    await $(Icons.logout).tap();
    await $.pumpAndSettle();
  }
}