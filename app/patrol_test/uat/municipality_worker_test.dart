import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/municipality_worker_robot.dart';

void main() {
  patrolTest('Editar estado do primeiro report', (
    PatrolIntegrationTester $,
  ) async {
    final loginRobot = LoginRobot($);
    final municipalityRobot = MunicipalityRobot($);

    await app.main();
    await $.pumpAndSettle();

    await loginRobot.fullLogin('joao@cmporto.com', 'joaosousa');
    await municipalityRobot.validateMunicipalityLoaded();

    await municipalityRobot.changeStatus('Em resolução');
    await municipalityRobot.changeStatus('Resolvido');
    await municipalityRobot.changeStatus('Pendente');
  });
}
