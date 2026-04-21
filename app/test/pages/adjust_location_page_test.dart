import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app/models/report_data.dart';
import 'package:app/pages/adjust_location_page.dart';
import 'package:app/widgets/primary_button.dart';

void main() {
  group('Adjust Location Page Tests', () {
    final initialReport = ReportData(
      category: 'Infraestrutura',
      title: 'Buraco',
      description: 'Estrada partida',
      latitude: 41.1496,
      longitude: -8.6109,
    );

    setUp(() {
      dotenv.clean();
    });

    Future<void> setupPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: AdjustLocationPage(report: initialReport)),
      );
    }

    testWidgets('Should show an error if the map API key does not exist', (
      WidgetTester tester,
    ) async {
      // Inject a dummy variable so dotenv initializes
      dotenv.loadFromString(envString: 'DUMMY_VARIABLE=true');

      await setupPage(tester);
      await tester.pumpAndSettle();

      expect(
        find.text('STADIA_MAPS_API_KEY não encontrada no .env'),
        findsOneWidget,
      );
      expect(find.byType(PrimaryButton), findsOneWidget);
    });

    testWidgets(
      'Should handle simulated geocoding network failure gracefully',
      (WidgetTester tester) async {
        // Inject a fake API key so the map attempts to render
        dotenv.loadFromString(
          envString: 'STADIA_MAPS_API_KEY=fake_test_key_123',
        );

        await setupPage(tester);
        await tester.pumpAndSettle();

        expect(
          find.text('Não foi possível obter a morada desta localização.'),
          findsOneWidget,
        );
      },
    );
  });
}
