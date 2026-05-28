import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/municipality_worker_robot.dart';

void main() {
  patrolTest('Editar estado e verificar após logout e pesquisa', (
    PatrolIntegrationTester $,
  ) async {
    final loginRobot = LoginRobot($);
    final municipalityRobot = MunicipalityRobot($);
    final homeRobot = HomeRobot($);

    await app.main();
    await $.pumpAndSettle();

    await loginRobot.fullLogin('joao@cmporto.com', 'joaosousa');
    await municipalityRobot.validateMunicipalityLoaded();

    final reportTitle = await municipalityRobot.getFirstReportTitle();

    await municipalityRobot.changeStatus('Em resolução');

    await municipalityRobot.tapLogout();

    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');
    await homeRobot.validateHomeLoaded();

    await homeRobot.searchReport(reportTitle);

    await homeRobot.validateReportWithStatus(reportTitle, 'Em resolução');
  });
}
