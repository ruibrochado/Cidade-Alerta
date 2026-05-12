import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

class MapRobot {
  final PatrolIntegrationTester $;
  MapRobot(this.$);

  Future<void> verifyMapIsVisible() async {
    await $('Mapa').waitUntilVisible();
  }
}
