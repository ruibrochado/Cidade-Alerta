import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

class ReportRobot {
  final PatrolIntegrationTester $;
  ReportRobot(this.$);

  Future<void> fillDetails(String title, String description) async {
    await $(TextField).at(0).enterText(title);
    await $(TextField).at(1).enterText(description);

    await $.tester.testTextInput.receiveAction(TextInputAction.done);

    await $('Continuar').tap();
    await $.pumpAndSettle();
  }

  Future<void> takePhoto() async {
    await $('Tirar Foto').waitUntilVisible();
    await $('Tirar Foto').tap();

    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }

    await $.native.tap(Selector(resourceId: 'com.android.camera2:id/shutter_button'));
    await $.native.tap(Selector(resourceId: 'com.android.camera2:id/done_button'));

    await $('Continuar').tap();
    await $.pumpAndSettle();
  }

  Future<void> confirmAndSend() async {
    await $('Enviar Denúncia').waitUntilVisible();
    await $('Enviar Denúncia').tap();

    await $('Denúncia Enviada!').waitUntilVisible();
  }
}