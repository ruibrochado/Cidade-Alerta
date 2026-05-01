import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

class RecycleRobot {
  final PatrolIntegrationTester $;
  RecycleRobot(this.$);

  Future<void> startScan() async {
    await $('Scan object').tap();

    if (await $.platform.mobile.isPermissionDialogVisible(
      timeout: const Duration(seconds: 5),
    )) {
      await $.platform.mobile.grantPermissionWhenInUse();
    }

    await Future.delayed(const Duration(seconds: 4));

    await $.platform.mobile.pressVolumeDown();

    await Future.delayed(const Duration(seconds: 4));

    try {
      await $.platform.mobile.tap(Selector(text: 'OK'));
    } catch (e) {
      try {
        await $.platform.mobile.tap(Selector(contentDescription: 'Done'));
      } catch (e2) {
        await $.platform.android.pressBack();
      }
    }

    await Future.delayed(const Duration(seconds: 3));
    await $.pump();
  }

  Future<void> verifyScanResult() async {
    await $('Recycling Scanner').waitUntilVisible();
  }
}