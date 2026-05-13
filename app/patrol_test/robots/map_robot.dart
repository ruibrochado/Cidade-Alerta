import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';

class MapRobot {
  final PatrolIntegrationTester $;
  MapRobot(this.$);

  // Agora é Future!
  Future<void> verifyMapIsVisible() async {
    // Garante que o titulo 'Mapa' está visível no ecrã antes de fechar o teste
    await $('Mapa').waitUntilVisible();
  }
}
