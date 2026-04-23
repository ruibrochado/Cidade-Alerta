import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';
import '../robots/nav_robot.dart';

void main() {
  patrolTest(
    'UAT 08: Open scanner, grant camera permission and process image' ,
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);
      final nav = NavRobot($);

      await auth.login('teste@cidadealerta.pt', '123456');

      await nav.goToScannerTab();

      await $('Scan object').tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await $.native.tap(Selector(resourceId: 'com.android.camera2:id/shutter_button'));

      await $.native.tap(Selector(resourceId: 'com.android.camera2:id/done_button'));

      await Future.delayed(const Duration(seconds: 3));

      expect($(Image), findsOneWidget);
      expect($('No scan yet'), findsNothing);
    },
  );
}