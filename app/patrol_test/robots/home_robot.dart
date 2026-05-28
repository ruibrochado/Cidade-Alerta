import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class HomeRobot {
  final PatrolIntegrationTester $;

  HomeRobot(this.$);

  Future<void> tapHomeTab() async {
    await $('Inicio').tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> tapRecycleTab() async {
    await $('Reciclar').tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> tapMapTab() async {
    await $('Mapa').tap();
    await Future.delayed(const Duration(seconds: 2));
    await $.pump();
  }

  Future<void> tapAddReport() async {
    await $(Icons.add).tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> validateHomeLoaded() async {
    await $('Denúncias').waitUntilVisible();
  }

  Future<void> searchReport(String query) async {
    await $(TextField).at(0).enterText(query);
    await $.tester.testTextInput.receiveAction(TextInputAction.search);
    await Future.delayed(const Duration(seconds: 2));
    await $.pumpAndSettle();
  }

  Future<void> validateReportWithStatus(
    String title,
    String expectedStatus,
  ) async {
    await $(title).waitUntilVisible();
    await $(expectedStatus).waitUntilVisible();
  }
}
