import 'package:patrol/patrol.dart';
import 'package:app/main.dart' as app;
import '../robots/login_robot.dart';
import '../robots/home_robot.dart';
import '../robots/report_robot.dart';

void main() {
  patrolTest('UAT: Complete Report Submission Flow', (
    PatrolIntegrationTester $,
  ) async {
    final loginRobot = LoginRobot($);
    final homeRobot = HomeRobot($);
    final reportRobot = ReportRobot($);

    await app.main();
    await $.pumpAndSettle();

    // 1. Authenticate user
    await loginRobot.fullLogin('uat@gmail.com', 'uatuat');

    // 2. Start new report using the big green '+' button
    await homeRobot.tapAddReport();

    // 3. Select category and fill text fields
    await reportRobot.openCategoryDropdown();
    // Re-select 'Infraestrutura' as requested
    await reportRobot.selectCategory('Infraestrutura');

    await reportRobot.fillReportDetails(
      title: 'Buraco gigante na estrada',
      description: 'Pneu do carro quase rebentou ao passar aqui.',
    );
    await reportRobot.tapContinue();

    // 4. Handle native camera
    await reportRobot.takePhoto();
    await reportRobot.tapContinue();

    // 5. Handle native GPS and confirm map location
    await reportRobot.handleLocationAndConfirm();

    // 6. Submit the final report
    await reportRobot.finalSubmit();
  });
}
