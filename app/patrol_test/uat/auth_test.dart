import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';

void main() {
  patrolTest('Login flow with robots', (PatrolIntegrationTester $) async {
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);

    await app.main();
    await $.pumpAndSettle();

    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');
    homeRobot.validateHomeLoaded();
  });
}
