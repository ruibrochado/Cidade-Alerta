import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class MunicipalityRobot {
  final PatrolIntegrationTester $;
  MunicipalityRobot(this.$);

  Future<void> validateMunicipalityLoaded() async {
    await $('Denúncias da comunidade').waitUntilVisible();
  }

  Future<String> getFirstReportTitle() async {
    await $.pumpAndSettle();
    final titleWidget = $(Key('first_report_title'));
    await titleWidget.waitUntilVisible();
    return (titleWidget.evaluate().first.widget as Text).data ?? '';
  }

  Future<void> tapEditStatus({int index = 0}) async {
    await $('Editar estado').at(index).tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pump();
  }

  Future<void> selectStatus(String status) async {
    await $(status).waitUntilVisible();
    await $(status).tap();
    await $('Confirmar').tap();
    await Future.delayed(const Duration(seconds: 1));
    await $.pumpAndSettle();
  }

  Future<void> validateStatus(String status) async {
    await $(status).waitUntilVisible();
  }

  Future<void> changeStatus(String status, {int reportIndex = 0}) async {
    await tapEditStatus(index: reportIndex);
    await selectStatus(status);
    await validateStatus(status);
  }

  Future<void> tapLogout() async {
    await $(Icons.logout).tap();
    await Future.delayed(const Duration(seconds: 2));
    await $.pumpAndSettle();
  }
}
