import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

class RecycleRobot {
  final PatrolIntegrationTester $;
  RecycleRobot(this.$);

  Future<void> startScan() async {
    await $('Scan object').tap();

    // 1. Lida com a permissão (se aparecer)
    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }

    // 2. PAUSA CRÍTICA: Dá tempo ao Android para abrir a Câmara por completo
    await Future.delayed(const Duration(seconds: 4));

    // 3. Tira a foto
    await $.native.pressVolumeDown();

    // 4. PAUSA CRÍTICA: Dá tempo à Câmara para processar o clique e mostrar o botão de aceitar
    await Future.delayed(const Duration(seconds: 4));

    // 5. Aceita a foto (Ataque em 3 frentes)
    try {
      // Tenta o "OK" normal
      await $.native.tap(Selector(text: 'OK'));
    } catch (e) {
      try {
        // Tenta o "Visto" (Checkmark) do emulador do Pixel
        await $.native.tap(Selector(contentDescription: 'Done'));
      } catch (e2) {
        // Último recurso
        await $.native.pressBack();
      }
    }

    // Dá tempo para a app voltar ao Flutter e processar a imagem
    await Future.delayed(const Duration(seconds: 3));
    await $.pump();
  }

  Future<void> verifyScanResult() async {
    // Fica à espera que a UI mude após o scan
    await $('Recycling Scanner').waitUntilVisible();
  }
}
