import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

class MapRobot {
  final PatrolIntegrationTester $;
  MapRobot(this.$);

  void verifyMapIsVisible() {
    // We check for the 'Mapa' title in the app bar to confirm we are on the screen
    expect($('Mapa'), findsOneWidget);
  }
}
