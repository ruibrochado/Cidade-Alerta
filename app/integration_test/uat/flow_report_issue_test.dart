import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';
import '../robots/report_robot.dart';

void main() {
  patrolTest(
    'UAT 01: User logs in and successfully submits a report',
        ($) async {

      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);
      final report = ReportRobot($);

      await auth.login('teste@cidadealerta.pt', '123456');


      await $('Infraestrutura').tap();
      await $.pumpAndSettle();

      await report.fillDetails(
          'Buraco perigoso na estrada',
          'Há um buraco muito fundo na Rua Principal que está a danificar pneus.'
      );

      await report.takePhoto();


      await $.pumpAndSettle();
      await $('Confirmar').tap();

      await report.confirmAndSend();

      expect($('Ticket Number'), findsOneWidget);
    },
  );
}