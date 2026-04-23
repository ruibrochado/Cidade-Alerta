import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/social_robot.dart';

void main() {
  patrolTest('UAT: Social Interactions Flow (Upvote & Comment)', (PatrolIntegrationTester $) async {
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);
    final socialRobot = SocialRobot($);

    await app.main();
    await $.pumpAndSettle();

    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');

    // Test Upvote
    await socialRobot.toggleUpvote();

    // Test Comment
    await socialRobot.openComments();

    final uniqueComment = 'Teste automatizado ${DateTime.now().millisecondsSinceEpoch}';
    await socialRobot.writeAndSubmitComment(uniqueComment);

    // Validate
    socialRobot.verifyCommentAdded(uniqueComment);
  });
}