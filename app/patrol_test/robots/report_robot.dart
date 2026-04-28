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
    // Fill title and description fields
    await $(TextField).at(0).enterText(title);
    await $(TextField).at(1).enterText(description);
  }

  Future<void> tapContinue() async {
    await $('Continuar').tap();
    await $.pumpAndSettle();
  }

  Future<void> takePhoto() async {
    // Tenta até 3 vezes abrir a câmara
    for (int attempt = 0; attempt < 3; attempt++) {
      await $('Tirar Foto').tap();

      if (await $.native.isPermissionDialogVisible()) {
        await $.native.grantPermissionWhenInUse();
      }

      await Future.delayed(const Duration(seconds: 4));

      // Verifica se a câmara abriu (se ainda vê 'Tirar Foto' é porque não abriu)
      final cameraDidNotOpen = await $('Tirar Foto').exists;
      if (cameraDidNotOpen) {
        // Câmara não abriu, tenta de novo
        await $.pumpAndSettle();
        continue;
      }

      // Câmara abriu, tira a foto
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
      return; // sucesso, sai do loop
    }

    // Se chegou aqui, falhou 3 vezes — continua sem foto
    await $('Continuar').tap();
    await $.pumpAndSettle();
  }
  Future<void> handleDetectLocation() async {
    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }

    await Future.delayed(const Duration(seconds: 3));
    await $.pumpAndSettle();

    // Aqui tanto pode ser 'Continuar' como 'Escolher no mapa'
    if (await $('Continuar').exists) {
      await $('Continuar').tap();
    } else {
      await $('Escolher no mapa').tap();
    }

    await $.pumpAndSettle();
  }

// Lida com o AdjustLocationPage (tem scroll com mapa)
  Future<void> handleAdjustLocation() async {
    await Future.delayed(const Duration(seconds: 3));
    FocusManager.instance.primaryFocus?.unfocus();
    await $.pumpAndSettle();

    // Arrasto por Coordenadas Absolutas (Força Bruta).
    // X=200 (meio do ecrã horizontal), Y=600 (fundo do ecrã, garantidamente fora do mapa).
    // O Offset(0, -400) puxa a página fortemente para cima.
    await $.tester.dragFrom(const Offset(200, 600), const Offset(0, -400));
    await $.pumpAndSettle();

    // Agora o botão está visível no ecrã. Clica nele.
    await $('Confirmar localização').tap();
    await $.pumpAndSettle();
  }

  Future<void> finalSubmit() async {
    await $('Enviar Denúncia').scrollTo(
      view: $(Scrollable).first,
    ).tap();

    await $.pumpAndSettle();
  }
}