import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart'; // Necessário para os Icons e ListView
// Substitui 'app' pelo nome real do teu package
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';

void main() {
  patrolTest(
    'UAT 06: User views the report feed',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);
      await auth.login('teste@cidadealerta.pt', '123456');

      await $('Viste algum problema\nna cidade?').waitUntilVisible();

      final hasReports = $(ListView).exists;
      final isEmpty = $('Nenhuma denúncia encontrada.').exists;

      expect(hasReports || isEmpty, isTrue);

      if (hasReports) {
        await $.tester.drag($(ListView), const Offset(0, -500));
        await $.pumpAndSettle();
      }
    },
  );
}