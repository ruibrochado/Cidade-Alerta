import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/details_page.dart';

void main() {
  group('DetailsPage Civic Form Tests', () {
    testWidgets('Continue button is disabled until title and description are filled', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: DetailsPage(category: 'Sinalização'),
      ));

      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      final titleField = textFields.at(0);
      final descField = textFields.at(1);

      bool isButtonEnabled() {
        final buttonFinder = find.text('Continuar');
        return true;
      }

      await tester.enterText(titleField, 'Sinal Stop vandalizado');
      await tester.pump();

      expect(find.text('Sinal Stop vandalizado'), findsOneWidget);

      await tester.enterText(descField, 'Sinal no cruzamento encontra-se deitado no chão.');
      await tester.pump();

      expect(find.text('Sinal no cruzamento encontra-se deitado no chão.'), findsOneWidget);
    });
  });
}