import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/report_data.dart';
import 'package:app/pages/photo_page.dart';
import 'package:app/widgets/primary_button.dart';

void main() {
  group('Photo Page Tests', () {
    final initialReport = ReportData(
      category: 'Infraestrutura',
      title: 'Buraco na Estrada',
      description: 'Na Rua Augusta.',
    );

    Future<void> setupPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: PhotoPage(report: initialReport)),
      );
    }

    testWidgets(
      'Should show the correct interface and the "Continuar" button',
      (WidgetTester tester) async {
        await setupPage(tester);

        expect(find.text('Adicionar Foto'), findsOneWidget);
        expect(find.byType(PrimaryButton), findsOneWidget);
        expect(find.text('Tirar Foto'), findsOneWidget);
      },
    );

    testWidgets(
      'Should show SnackBar if the user tries to continue without taking a photo',
      (WidgetTester tester) async {
        await setupPage(tester);

        final buttonFinder = find.byType(PrimaryButton);

        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();

        expect(find.text('Adiciona uma foto primeiro'), findsOneWidget);
      },
    );
  });
}
