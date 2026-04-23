import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

class RecycleRobot {
  final PatrolIntegrationTester $;
  RecycleRobot(this.$);

  Future<void> startScan() async {
    await $('Scan object').tap();

    // Handle camera permission
    if (await $.native.isPermissionDialogVisible()) {
      await $.native.grantPermissionWhenInUse();
    }

    // Emulate taking a photo
    await $.native.pressVolumeDown();
    await Future.delayed(const Duration(seconds: 2));

    // Accept photo
    try {
      await $.native.tap(Selector(text: 'OK'));
    } catch (e) {
      await $.native.pressBack();
    }

    await $.pumpAndSettle();
  }

  void verifyScanResult() {
    // Verifies that the text changed from 'No scan yet'
    // Since the result might vary, we can check for 'Unknown item' as in your screenshot
    expect($('Unknown item'), findsOneWidget);
  }
}