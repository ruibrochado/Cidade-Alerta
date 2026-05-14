// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart'; // Necessário para encontrar o Icons.person
import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/register_robot.dart';
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';

void main() {
  patrolTest('UAT: Registration, Initial Login and Account Deletion Flow', (
    PatrolIntegrationTester $,
  ) async {
    final registerRobot = RegisterRobot($);
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);

    await app.main();
    await $.pumpAndSettle();

    await $('Criar Conta').tap();
    await $.pumpAndSettle();

    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final dynamicEmail = 'novo.user+$uniqueId@gmail.com';

    await registerRobot.fillRegistrationForm(
      firstName: 'Novo',
      lastName: 'Utilizador',
      email: dynamicEmail,
      password: 'password123',
    );

    await registerRobot.tapSubmit();

    await $('OK').tap();
    await $.pumpAndSettle();

    await loginRobot.fullLogin(dynamicEmail, 'password123');

    try {
      await $.native.grantPermissionWhenInUse();
    } catch (_) {}

    await homeRobot.validateHomeLoaded();

    await $(Icons.person).tap();
    await $.pumpAndSettle();

    await $('Eliminar conta').scrollTo().tap();
    await $.pumpAndSettle();

    await $('Eliminar').tap();
    await $.pumpAndSettle();
  });
}
