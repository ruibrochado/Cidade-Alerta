import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Sign in redirects user to Home page', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(loginButton, findsOneWidget);

    await tester.enterText(emailField, 'test@gmail.con');
    await tester.pump(const Duration(seconds: 1));
    await tester.enterText(passwordField, 'test1234');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Hi! my name is Rui'), findsOneWidget);
  });
}