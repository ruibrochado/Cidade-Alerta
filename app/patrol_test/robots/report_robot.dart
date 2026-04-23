import 'package:patrol/patrol.dart';
import 'package:flutter/material.dart';

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
    // Fill title and description fields
    await $(TextField).at(0).enterText(title);
    await $(TextField).at(1).enterText(description);
  }

  Future<void> tapContinue() async {
    await $('Continuar').tap();
    await $.pumpAndSettle();
  }

  Future<void> takePhoto() async {
    await $('Tirar Foto').tap();

    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }

    await Future.delayed(const Duration(seconds: 4));

    await $.native.pressVolumeDown();

    await Future.delayed(const Duration(seconds: 4));

    try {
      await $.native.tap(Selector(text: 'OK'));
    } catch (e) {
      try {
        await $.native.tap(Selector(contentDescription: 'Done'));
      } catch (e2) {
        await $.native.pressBack();
      }
    }

    await $.pumpAndSettle();
  }

  Future<void> handleLocationAndConfirm() async {
    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }

    await Future.delayed(const Duration(seconds: 2));
    await $.pumpAndSettle();

    final hasContinuar = await $('Continuar').exists;

    if (hasContinuar) {
      await $('Continuar').last.tap();
    } else {
      await $('Confirmar localização').scrollTo(
        view: $(Scrollable).last,
      ).tap();
    }

    await $.pumpAndSettle();
  }

  Future<void> finalSubmit() async {
    await $('Enviar Denúncia').scrollTo(
      view: $(Scrollable).first,
    ).tap();

    await $.pumpAndSettle();
  }
}