import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/register_robot.dart';
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';

void main() {
  patrolTest('UAT: Registration and Initial Login Flow', (
    PatrolIntegrationTester $,
  ) async {
    final registerRobot = RegisterRobot($);
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);

    await app.main();
    await $.pumpAndSettle();

    await $('Criar Conta').tap();
    await $.pumpAndSettle();

    // Generates a unique email to bypass database unique constraints on repeated test runs
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final dynamicEmail = 'novo.user+$uniqueId@gmail.com';

    await registerRobot.fillRegistrationForm(
      firstName: 'Novo',
      lastName: 'Utilizador',
      email: dynamicEmail,
      password: 'password123',
    );

    await registerRobot.tapSubmit();

    await loginRobot.fullLogin(dynamicEmail, 'password123');
    await homeRobot.validateHomeLoaded();
  });
}
