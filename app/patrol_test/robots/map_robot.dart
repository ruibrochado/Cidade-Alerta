import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

class MapRobot {
  final PatrolIntegrationTester $;
  MapRobot(this.$);

  Future<void> verifyMapIsVisible() async {
    await $('Mapa').waitUntilVisible();
  }

  Future<void> tapFirstIssuePin() async {
    await $(const Key('issue_marker')).first.tap();
    await $.pumpAndSettle();
  }
}
