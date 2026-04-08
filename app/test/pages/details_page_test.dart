import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/details_page.dart';
import 'package:app/pages/photo_page.dart';
import 'package:app/widgets/primary_button.dart';

void main() {
  group('Details Page Tests (Updated)', () {

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
      
      final titleFinder = find.byType(TextField).first;
      final descFinder = find.byType(TextField).last;

      // checks if the button starts disabled (onPressed == null)
      expect(tester.widget<PrimaryButton>(buttonFinder).onPressed, isNull);

      // fills only the title section
      await tester.enterText(titleFinder, 'Buraco perigoso');
      await tester.pumpAndSettle(); // guarantees that the UI has been updated
      expect(tester.widget<PrimaryButton>(buttonFinder).onPressed, isNull);

      // fills the description section
      await tester.enterText(descFinder, 'Perto da escola.');
      await tester.pumpAndSettle();
      // the button should be active now
      expect(tester.widget<PrimaryButton>(buttonFinder).onPressed, isNotNull); 

      // deletes the title (button should be disabled now)
      await tester.enterText(titleFinder, '');
      await tester.pumpAndSettle();
      expect(tester.widget<PrimaryButton>(buttonFinder).onPressed, isNull);
    });

    testWidgets('Should navigate to PhotoPage with report data when Continue is tapped', (WidgetTester tester) async {
      await setupPage(tester);

      final buttonFinder = find.byType(PrimaryButton);

      final titleFinder = find.byType(TextField).first;
      final descFinder = find.byType(TextField).last;

      // activates the button
      await tester.enterText(titleFinder, 'Tubo partido');
      await tester.enterText(descFinder, 'Água a jorrar no passeio.');
      await tester.pumpAndSettle();

      await tester.ensureVisible(buttonFinder);
      await tester.pumpAndSettle(); 

      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // confirms that we went to the PhotoPage
      expect(find.byType(PhotoPage), findsOneWidget);
    });

  });
}