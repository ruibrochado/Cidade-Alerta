import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('Teste de Aceitação: Fluxo de Login e Identificação', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    final userField = find.byKey(const Key('userField'));
    final passField = find.byKey(const Key('passField'));
    final loginButton = find.byKey(const Key('loginButton'));


    await tester.enterText(userField, 'pedro_domingos');
    await tester.enterText(passField, 'feup_2024');

    await tester.tap(loginButton);

    await tester.pumpAndSettle();

    expect(find.text('Olá, o meu nome é Pedro Domingos!'), findsOneWidget);

    expect(find.text('FEUP Test - Home'), findsOneWidget);
  });
}
