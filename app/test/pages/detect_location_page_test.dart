import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/report_data.dart';
import 'package:app/pages/detect_location_page.dart';
import 'package:app/widgets/primary_button.dart';

void main() {
  group('Detect Location Page Tests', () {

    final initialReport = ReportData(
      category: 'Limpeza',
      title: 'Caixote Lixo',
      description: 'A transbordar.',
      photos: ['/caminho/falso/foto.jpg'],
    );

    Future<void> setupPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          // injected the route because the "Continuar" button does Navigator.pushNamed()
          routes: {
            '/adjust-location': (context) => const Scaffold(body: Text('Página do Mapa')),
          },
          home: DetectLocationPage(report: initialReport),
        ),
      );
    }

    testWidgets('Should show the loading state', (WidgetTester tester) async {
      await setupPage(tester);

      // Right when the page opens, it should be looking for the location
      expect(find.text('Localização'), findsOneWidget);
      expect(find.text('Detectando sua localização...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Button should be blocked during detection
      final buttonFinder = find.byType(PrimaryButton);
      expect(tester.widget<PrimaryButton>(buttonFinder).enabled, isFalse);
    });
  });
}