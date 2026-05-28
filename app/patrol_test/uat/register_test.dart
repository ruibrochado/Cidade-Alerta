// ignore_for_file: deprecated_member_use
import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/register_robot.dart';
import '../robots/home_robot.dart';
import '../robots/profile_robot.dart';

void main() {
  patrolTest(
    'UAT: Registration, Edit Profile, Terms and Account Deletion Flow',
    (PatrolIntegrationTester $) async {
      final registerRobot = RegisterRobot($);
      final homeRobot = HomeRobot($);
      final profileRobot = ProfileRobot($);

      await app.main();
      await $.pumpAndSettle();

      await $('Criar Conta').tap();
      await $.pumpAndSettle();

      final uniqueId = DateTime.now().millisecondsSinceEpoch;
      final dynamicEmail = 'novo.user+$uniqueId@gmail.com';

      await registerRobot.fillRegistrationForm(
        firstName: 'Novo',
        lastName: 'Utilizador',
        email: dynamicEmail,
        password: 'password123',
      );

      await registerRobot.tapSubmit();

      await $.pumpAndSettle();
      await $('OK').tap();

      if (await $.platform.mobile.isPermissionDialogVisible(
        timeout: const Duration(seconds: 5),
      )) {
        await $.platform.mobile.grantPermissionWhenInUse();
      }

      await homeRobot.validateHomeLoaded();

      await profileRobot.tapProfileIcon();

      await profileRobot.openAndCloseTerms();

      final dataAtual = DateTime.now();
      final horaMinuto = '${dataAtual.hour}h${dataAtual.minute}';
      final novoNome = 'User$horaMinuto';
      final novoApelido = 'Teste${dataAtual.second}';

      await profileRobot.editProfileAndSave(novoNome, novoApelido);

      await profileRobot.deleteAccount();
    },
  );
}
