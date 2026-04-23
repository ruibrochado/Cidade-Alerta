import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/details_page.dart';
import 'package:app/widgets/primary_button.dart';

void main() {
  testWidgets('PROFUNDO: Continuar button must remain disabled until all fields are valid', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: DetailsPage(category: 'Infraestrutura'),
    ));

    final buttonFinder = find.byType(PrimaryButton);
    PrimaryButton button = tester.widget(buttonFinder);
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(0), 'Buraco na rua');
    await tester.pumpAndSettle();

    button = tester.widget(buttonFinder);
    expect(button.onPressed, isNull);

    await tester.enterText(find.byType(TextField).at(1), 'Descrição muito detalhada do problema');
    await tester.pumpAndSettle();

    button = tester.widget(buttonFinder);
    expect(button.onPressed, isNotNull);
  });
}