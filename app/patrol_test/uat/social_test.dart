import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/social_robot.dart';

void main() {
  patrolTest('UAT: Social Interactions Flow', (
    PatrolIntegrationTester $,
  ) async {
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);
    final socialRobot = SocialRobot($);

    await app.main();
    await Future.delayed(const Duration(seconds: 3));
    await $.pump();

    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');
    await homeRobot.validateHomeLoaded();

    await socialRobot.tapUpvote(); // Mete Like
    await socialRobot.tapUpvote(); // Tira Like

    await socialRobot.tapDownvote(); // Mete Dislike
    await socialRobot.tapDownvote(); // Tira Dislike

    await socialRobot.openComments();
    final uniqueComment =
        'Teste automatizado ${DateTime.now().millisecondsSinceEpoch}';

    await socialRobot.writeAndSubmitComment(uniqueComment);

    await socialRobot.closeComments();

    await homeRobot.validateHomeLoaded();
  });
}
