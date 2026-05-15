// ignore_for_file: deprecated_member_use
import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class ActivityRobot {
  final PatrolIntegrationTester $;

  ActivityRobot(this.$);

  Future<void> tapActivityTab() async {
    await $('Atividade').tap();
  }

  Future<void> tapFirstActivity() async {
    await $(ListView).waitUntilVisible(timeout: const Duration(seconds: 15));

    await $(ListView).$(InkWell).first.tap();

    await $.pumpAndSettle();
  }

  Future<void> verifyCommentSheetOpenedAndClose() async {
    await Future.delayed(const Duration(seconds: 2));

    await $.native.pressBack();

    await Future.delayed(const Duration(seconds: 1));
  }
}
