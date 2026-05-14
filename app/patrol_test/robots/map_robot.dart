import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class MapRobot {
  final PatrolIntegrationTester $;
  MapRobot(this.$);

  Future<void> verifyMapIsVisible() async {
    // IMPORTANT: Teleport to Lisbon (Portugal) so the markers load
    // This prevents the bot from being stuck in the USA (default emulator location)
    //await $.native.setMockLocation(38.7223, -9.1393);

    await $('Mapa').waitUntilVisible();
    await $.pumpAndSettle();
  }

  Future<void> tapFirstIssuePin() async {
    await $(const Key('issue_marker')).first.waitUntilVisible();
    await $(const Key('issue_marker')).first.tap();
    await $.pumpAndSettle();
  }

  Future<void> findAndTapEcocenterPin() async {
    bool pinFound = false;
    int maxAttempts = 10;

    for (int i = 0; i < maxAttempts; i++) {
      if ($(const Key('ecocenter_marker')).exists) {
        pinFound = true;
        break;
      }

      if ($(const Key('ecocenter_cluster')).exists) {
        await $(const Key('ecocenter_cluster')).first.tap();
        await $.pumpAndSettle();
        continue;
      }

      // If nothing found, drag to explore
      await $.tester.drag(find.byType(Stack).first, const Offset(0, -300));
      await $.pumpAndSettle();
    }

    if (pinFound) {
      await $(const Key('ecocenter_marker')).first.tap();
      await $.pumpAndSettle();
    } else {
      throw Exception('Ecocenter pin not found after exploring the map');
    }
  }

  Future<void> verifyEcocenterDetailsVisible() async {
    await $('Detalhes do Ecocentro').waitUntilVisible();
    await $(Icons.close).tap();
    await $.pumpAndSettle();
  }
}
