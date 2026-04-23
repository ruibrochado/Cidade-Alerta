import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/register_robot.dart';
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';

void main() {
  patrolTest('UAT: Registration and Initial Login Flow', (PatrolIntegrationTester $) async {
    final registerRobot = RegisterRobot($);
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);

    await app.main();
    await $.pumpAndSettle();

    // 1. Navigate to Register Page
    await $('Clica aqui').tap();
    await $.pumpAndSettle();

    // 🧠 O TRUQUE PARA NÃO SER BURRO: Gerar email único
    final uniqueId = DateTime.now().millisecondsSinceEpoch;
    final dynamicEmail = 'novo.user+$uniqueId@gmail.com';

    // 2. Fill the registration form com o email dinâmico
    await registerRobot.fillRegistrationForm(
      firstName: 'Novo',
      lastName: 'Utilizador',
      email: dynamicEmail,
      password: 'password123',
    );

    // 3. Submit registration
    await registerRobot.tapSubmit();

    // 4. Perform Login com o MESMO email que acabámos de gerar
    await loginRobot.fullLogin(dynamicEmail, 'password123');

    // 5. Verify we successfully entered the app
    homeRobot.validateHomeLoaded();
  });
}