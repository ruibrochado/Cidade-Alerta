import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class NavRobot {
  final PatrolIntegrationTester $;
  NavRobot(this.$);

  Future<void> goToActivity() async {
    await $('Atividade').tap();
    await $.pumpAndSettle();
  }

  Future<void> goToMap() async {
    await $(Icons.map).tap();
    await $.pumpAndSettle();
  }

  Future<void> tapReportButton() async {
    await $(Icons.add).tap();
    await $.pumpAndSettle();
  }

  Future<void> goToMapTab() async {
    await $(Icons.map).tap();
    await $.pumpAndSettle();
  }

  Future<void> goToScannerTab() async {
    await $(Icons.qr_code_scanner).tap();
    await $.pumpAndSettle();
  }
}