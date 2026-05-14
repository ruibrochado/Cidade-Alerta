import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/map_robot.dart';
import '../robots/social_robot.dart'; // <--- Importamos o teu SocialRobot!

void main() {
  patrolTest('UAT: Tapping an issue pin on the map opens details', (
    PatrolIntegrationTester $,
  ) async {
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);
    final mapRobot = MapRobot($);
    final socialRobot = SocialRobot($);

    await app.main();
    await $.pumpAndSettle();

    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');

    await homeRobot.tapMapTab();
    await mapRobot.verifyMapIsVisible();

    await mapRobot.tapFirstIssuePin();

    await socialRobot.verifyReportDetailsVisible();

    await socialRobot.closeComments();
  });
}
