import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ReportRobot {
  final PatrolIntegrationTester $;
  ReportRobot(this.$);

  Future<void> openCategoryDropdown() async {
    await $('Infraestrutura').tap();
    await $.pumpAndSettle();
  }

  Future<void> selectCategory(String categoryName) async {
    await $(categoryName).tap();
    await $.pumpAndSettle();
  }

  Future<void> fillReportDetails({
    required String title,
    required String description,
  }) async {
    await $(TextField).at(0).enterText(title);
    await $(TextField).at(1).enterText(description);
  }

  Future<void> tapContinue() async {
    await $('Continuar').tap();
    await $.pumpAndSettle();
  }

  Future<void> takePhoto() async {
    for (int attempt = 0; attempt < 3; attempt++) {
      await $('Tirar Foto').tap();

      if (await $.platform.mobile.isPermissionDialogVisible(
        timeout: const Duration(seconds: 5),
      )) {
        await $.platform.mobile.grantPermissionWhenInUse();
      }

      await Future.delayed(const Duration(seconds: 4));

      final cameraDidNotOpen = $('Tirar Foto').exists;
      if (cameraDidNotOpen) {
        await $.pumpAndSettle();
        continue;
      }

      await $.platform.mobile.pressVolumeDown();
      await Future.delayed(const Duration(seconds: 4));

      // recycle_robot.dart e report_robot.dart
      try {
        await $.platform.mobile.tap(Selector(text: 'OK'));
      } catch (e) {
        try {
          await $.platform.mobile.tap(Selector(contentDescription: 'Done'));
        } catch (e2) {
          await $.platform.android.pressBack(); // ← android-only
        }
      }

      await $.pumpAndSettle();
      return;
    }

    await $('Continuar').tap();
    await $.pumpAndSettle();
  }

  Future<void> handleDetectLocation() async {
    if (await $.platform.mobile.isPermissionDialogVisible(
      timeout: const Duration(seconds: 5),
    )) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }

    await Future.delayed(const Duration(seconds: 3));
    await $.pumpAndSettle();

    if ($('Continuar').exists) {
      await $('Continuar').tap();
    } else {
      await $('Escolher no mapa').tap();
    }

    await $.pumpAndSettle();
  }

  Future<void> handleAdjustLocation() async {
    await Future.delayed(const Duration(seconds: 3));
    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndSettle();

    await $.tester.dragFrom(const Offset(200, 600), const Offset(0, -400));
    await $.pumpAndSettle();

    await $('Confirmar localização').tap();
    await $.pumpAndSettle();
  }

  Future<void> finalSubmit() async {
    await $('Enviar Denúncia').scrollTo(view: $(Scrollable).first).tap();
    await $.pumpAndSettle();
  }
}
