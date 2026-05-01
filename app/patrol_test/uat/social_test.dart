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

    // 1. Fazer Login
    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');
    await homeRobot.validateHomeLoaded();

    // 2. Testar Upvote (Like)
    await socialRobot.tapUpvote(); // Mete Like
    await socialRobot.tapUpvote(); // Tira Like

    // 3. Testar Downvote (Dislike)
    await socialRobot.tapDownvote(); // Mete Dislike
    await socialRobot.tapDownvote(); // Tira Dislike

    // 4. Testar Comentário
    await socialRobot.openComments();
    final uniqueComment =
        'Teste automatizado ${DateTime.now().millisecondsSinceEpoch}';

    // Escreve e envia
    await socialRobot.writeAndSubmitComment(uniqueComment);

    // 5. Sai da zona de comentários (Clica no X)
    await socialRobot.closeComments();

    // Opcional: Podes validar que voltaste à Home page garantindo que vês o ecrã principal
    await homeRobot.validateHomeLoaded();
  });
}
