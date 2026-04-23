import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Citizen Report Story UAT', () {
    testWidgets('Citizen creates a report from category to details', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      final createReportBtn = find.text('Create a Report');
      if (findsWidgets.matches(createReportBtn, {})) {
        await tester.tap(createReportBtn.first);
        await tester.pumpAndSettle();
      }

      expect(find.text('Criar Denúncia'), findsOneWidget);

      final categoryCard = find.text('Infraestrutura');
      await tester.tap(categoryCard);
      await tester.pumpAndSettle();

      expect(find.text('Descrever Problema'), findsOneWidget);
      expect(find.text('Infraestrutura'), findsWidgets);

      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));

      await tester.enterText(textFields.at(0), 'Buraco na Estrada N12');
      await tester.pumpAndSettle();

      await tester.enterText(textFields.at(1), 'Existe um buraco profundo na via direita que danifica pneus.');
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      final continueButton = find.text('Continuar');
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Adicionar Foto'), findsOneWidget);
    });
  });
}