import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/report_data.dart';
import 'package:app/pages/confirm_report_page.dart';
import 'package:app/widgets/primary_button.dart';

void main() {
  group('Confirm Report Page Tests', () {
    final reportToSubmit = ReportData(
      category: 'Iluminação',
      title: 'Lâmpada fundida',
      description: 'Poste escuro na passadeira.',
      latitude: 41.1496,
      longitude: -8.6109,
      photos: [],
    );

    Future<void> setupPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Page')),
          },
          home: ConfirmPage(report: reportToSubmit),
        ),
      );
    }

    testWidgets('Should display report summary correctly', (
      WidgetTester tester,
    ) async {
      await setupPage(tester);
      await tester.pumpAndSettle();

      expect(find.text('Confirmar Denúncia'), findsOneWidget);
      expect(find.text('Iluminação'), findsOneWidget);
      expect(find.text('Lâmpada fundida'), findsOneWidget);
      expect(find.text('Poste escuro na passadeira.'), findsOneWidget);
      expect(find.text('Enviar Denúncia'), findsOneWidget);
    });

    testWidgets(
      'Should handle backend failure, unlock button, and show SnackBar',
      (WidgetTester tester) async {
        await setupPage(tester);
        await tester.pumpAndSettle();

        final buttonFinder = find.byType(PrimaryButton);

        await tester.tap(buttonFinder);

        // Use pumpAndSettle to wait for the entire failure process and SnackBar animation to finish
        await tester.pumpAndSettle();

        // 1. Verify the button unlocked and reset its text
        expect(find.text('Enviar Denúncia'), findsOneWidget);

        // 2. Verify the catch block triggered the error SnackBar
        expect(
          find.textContaining('Erro ao guardar denúncia:'),
          findsOneWidget,
        );
      },
    );
  });
}
