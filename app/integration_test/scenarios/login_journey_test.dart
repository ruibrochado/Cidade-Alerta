import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Citizen Authentication Journey UAT', () {
    testWidgets('Citizen logs in and accesses the civic dashboard', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Password');
      final loginButton = find.widgetWithText(ElevatedButton, 'Login');

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);

      await tester.enterText(emailField, 'cidadania@lisboa.pt');
      await tester.pumpAndSettle();

      await tester.enterText(passwordField, 'Seguranca123!');
      await tester.pumpAndSettle();

      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      expect(find.byType(BottomNavigationBar), findsWidgets);
    });
  });
}