import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';

void main() {
  patrolTest(
    'UAT 10: User tries to login without internet connection',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);

      await $.native.disableWifi();
      await $.native.disableCellular();

      await auth.login('teste@cidadealerta.pt', '123456');

      await $('Failed to fetch').waitUntilVisible();

      await $.native.enableWifi();
      await $.native.enableCellular();
    },
  );
}