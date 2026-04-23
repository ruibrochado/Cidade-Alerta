import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';
import '../robots/nav_robot.dart';

void main() {
  patrolTest(
    'UAT 04: Tab navigation and opening the report flow',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);
      final nav = NavRobot($);

      await auth.login('teste@cidadealerta.pt', '123456');

      await nav.goToActivity();

      await $('Atividade').waitUntilVisible();

      await nav.tapReportButton();

      await $('Criar Denúncia').waitUntilVisible();
    },
  );
}