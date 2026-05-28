import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class MapRobot {
  final PatrolIntegrationTester $;
  MapRobot(this.$);

  Future<void> verifyMapIsVisible() async {
    await $('Mapa').waitUntilVisible();
    await $.pumpAndSettle();
  }

  Future<void> _zoomOut() async {
    final center = $.tester.getCenter(find.byType(Stack).first);

    final gesture1 = await $.tester.startGesture(
      center + const Offset(-150, 0),
    );
    final gesture2 = await $.tester.startGesture(center + const Offset(150, 0));

    await gesture1.moveTo(center + const Offset(-20, 0));
    await gesture2.moveTo(center + const Offset(20, 0));

    await $.tester.pump(const Duration(milliseconds: 300));
    await gesture1.up();
    await gesture2.up();
    await $.pumpAndSettle();
  }

  Future<void> tapFirstIssuePin() async {
    for (int i = 0; i < 15; i++) {
      if ($(const Key('issue_marker')).exists) {
        await $(const Key('issue_marker')).first.tap();
        await $.pumpAndSettle();
        return;
      }

      await _zoomOut();
    }
  }

  Future<void> findAndTapEcocenterPin() async {
    for (int i = 0; i < 15; i++) {
      if ($(const Key('ecocenter_marker')).exists) {
        await $(const Key('ecocenter_marker')).first.tap();
        await $.pumpAndSettle();
        return;
      }

      if ($(const Key('ecocenter_cluster')).exists) {
        await $(const Key('ecocenter_cluster')).first.tap();
        await $.pumpAndSettle();
        return;
      }

      await _zoomOut();
    }
  }

  Future<void> verifyEcocenterDetailsVisible() async {
    await $('Detalhes do Ecocentro').waitUntilVisible();
    await $(Icons.close).tap();
    await $.pumpAndSettle();
  }
}
