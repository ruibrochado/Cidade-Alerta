import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/recycle_robot.dart';

void main() {
  patrolTest('UAT: Recycling Scanner Flow', (PatrolIntegrationTester $) async {
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);
    final recycleRobot = RecycleRobot($);

    await app.main();
    await $.pumpAndSettle();

    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');

    // Navigate to Recycle tab
    await homeRobot.tapRecycleTab();

    // Perform scan
    await recycleRobot.startScan();

    // Validate result
    await recycleRobot.verifyScanResult();
  });
}