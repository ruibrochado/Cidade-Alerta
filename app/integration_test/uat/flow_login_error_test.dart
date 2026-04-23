import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';

void main() {
  patrolTest(
    'UAT 03: User inputs invalid credentials',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);

      await auth.login('inexistente@cidadealerta.pt', 'palavrapasseerrada');

      await $('Invalid login credentials').waitUntilVisible();
    },
  );
}