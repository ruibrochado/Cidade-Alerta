import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/map_robot.dart';

void main() {
  patrolTest('UAT: Map Navigation Flow', (PatrolIntegrationTester $) async {
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);
    final mapRobot = MapRobot($);

    await app.main();
    await $.pumpAndSettle();

    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');

    // Navigate to Map tab
    await homeRobot.tapMapTab();

    // Verify map screen
    await mapRobot.verifyMapIsVisible();
  });
}