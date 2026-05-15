import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/map_robot.dart';
import '../robots/social_robot.dart';

void main() {
  patrolTest('UAT: Tapping map pins opens respective details', (
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

    // 1. Issue Pin Flow (Red)
    await mapRobot.tapFirstIssuePin();
    await socialRobot.verifyReportDetailsVisible();
    await socialRobot.closeComments(); // Ensure sheet is fully closed

    // 2. Ecocenter Pin Flow (Green)
    await mapRobot.findAndTapEcocenterPin();
    await mapRobot.verifyEcocenterDetailsVisible();
  });
}
