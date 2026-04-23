import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart' as app;
import '../robots/auth_robot.dart';

void main() {
  patrolTest(
    'UAT 02: New user signs up and returns to login',
        ($) async {
      app.main();
      await $.pumpAndSettle();

      final auth = AuthRobot($);

      await auth.goToSignUp();

      final uniqueEmail = 'novo_user_${DateTime.now().millisecondsSinceEpoch}@teste.pt';

      await auth.signUp('João', 'Silva', uniqueEmail, 'password123');

      expect($('Login'), findsWidgets);
    },
  );
}