import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

class RecycleRobot {
  final PatrolIntegrationTester $;
  RecycleRobot(this.$);

  Future<void> startScan() async {
    await $('Scan object').tap();

    // Handle camera permission
    // ignore: deprecated_member_use
    if (await $.native.isPermissionDialogVisible()) {
      // ignore: deprecated_member_use
      await $.native.grantPermissionWhenInUse();
    }

    // Emulate taking a photo
    // ignore: deprecated_member_use
    await $.native.pressVolumeDown();
    await Future.delayed(const Duration(seconds: 2));

    // Accept photo
    try {
      // ignore: deprecated_member_use
      await $.native.tap(Selector(text: 'OK'));
    } catch (e) {
      // ignore: deprecated_member_use
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
