import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';
import '../robots/nav_robot.dart';

void main() {
  patrolTest(
    'UAT 07: Grant location permission and load map',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);
      final nav = NavRobot($);

      await auth.login('teste@cidadealerta.pt', '123456');

      await nav.goToMapTab();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await $('Mapa').waitUntilVisible();

      expect($(Icons.my_location), findsOneWidget);
    },
  );
}