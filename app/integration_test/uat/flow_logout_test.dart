import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';

void main() {
  patrolTest(
    'UAT 05: User logs out and returns to login screen',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);

      await auth.login('teste@cidadealerta.pt', '123456');

      await $(Icons.logout).waitUntilVisible();

      await auth.logout();

      await $('Email').waitUntilVisible();
      expect($('Login'), findsWidgets);
    },
  );
}