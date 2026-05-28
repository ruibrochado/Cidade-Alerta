import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;

import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/activity_robot.dart';

void main() {
  patrolTest(
    'UAT: User can navigate to Activity and open a comment notification',
    (PatrolIntegrationTester $) async {
      final loginRobot = LoginRobot($);
      final homeRobot = HomeRobot($);
      final activityRobot = ActivityRobot($);

      await app.main();
      await $.pumpAndSettle();

      await loginRobot.fullLogin('uat@gmail.com', 'uatuat');
      await homeRobot.validateHomeLoaded();

      await activityRobot.tapActivityTab();

      await activityRobot.tapFirstActivity();

      await activityRobot.verifyCommentSheetOpenedAndClose();
    },
  );
}
