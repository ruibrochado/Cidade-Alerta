import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/details_page.dart';
import 'package:app/pages/photo_page.dart';
import 'package:app/widgets/primary_button.dart';

void main() {
  group('Details Page Tests', () {

    Future<void> setupPage(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DetailsPage(category: 'Infraestrutura'),
        ),
      );
    }

    testWidgets('Primary button should only enable when both title and description are filled', (WidgetTester tester) async {
      await setupPage(tester);

      final buttonFinder = find.byType(PrimaryButton);
      
      // category is 0, title is 1 and desc is 2
      final titleFinder = find.byType(TextField).at(1);
      final descFinder = find.byType(TextField).at(2);

      expect(tester.widget<PrimaryButton>(buttonFinder).enabled, isFalse);

      await tester.enterText(titleFinder, 'Buraco perigoso');
      await tester.pump();
      expect(tester.widget<PrimaryButton>(buttonFinder).enabled, isFalse);

      // the button should activate after both fields are filled
      await tester.enterText(descFinder, 'Perto da escola.');
      await tester.pump();
      expect(tester.widget<PrimaryButton>(buttonFinder).enabled, isTrue); 

      // the button should block when we remove one of the fields
      await tester.enterText(titleFinder, '');
      await tester.pump();
      expect(tester.widget<PrimaryButton>(buttonFinder).enabled, isFalse);
    });

    testWidgets('Should navigate to PhotoPage with report data when Continue is tapped', (WidgetTester tester) async {
      await setupPage(tester);

      final buttonFinder = find.byType(PrimaryButton);

      final titleFinder = find.byType(TextField).at(1);
      final descFinder = find.byType(TextField).at(2);

      // fill the fields to activate the button
      await tester.enterText(titleFinder, 'Tubo partido');
      await tester.enterText(descFinder, 'Água a jorrar no passeio.');
      await tester.pump();

      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle(); // wait for the test "bot" to find the button

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // confirm that we go to a PhotoPage
      expect(find.byType(PhotoPage), findsOneWidget);
    });

  });
}