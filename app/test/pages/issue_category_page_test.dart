import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/issue_category_page.dart'; 
import 'package:app/pages/details_page.dart';

void main() {
  group('SelectCategory UI Tests', () {
    
    Future<void> setupPage(WidgetTester tester) async {
      // Ensure the screen is large enough to render all grid items
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        const MaterialApp(
          home: SelectCategory(),
        ),
      );
    }

    testWidgets('Should render headers and exactly 6 grid categories', (WidgetTester tester) async {
      await setupPage(tester);
      await tester.pumpAndSettle();

      // Verify header text
      expect(find.text('Criar Denúncia'), findsOneWidget);
      
      // Target only InkWells that are inside the GridView (we do this so it doesnt count the back button)
      final gridFinder = find.byType(GridView);
      final categoryButtonsFinder = find.descendant(
        of: gridFinder, 
        matching: find.byType(InkWell)
      );

      expect(categoryButtonsFinder, findsNWidgets(6));
    });

    testWidgets('Should navigate to the Details Page when a category is tapped', (WidgetTester tester) async {
      await setupPage(tester);
      await tester.pumpAndSettle();

      final firstCategoryFinder = find.text('Infraestrutura');
      await tester.tap(firstCategoryFinder);

      await tester.pumpAndSettle();

      // Confirm transition to the next step of the reporting feature
      expect(find.byType(DetailsPage), findsOneWidget);
      expect(find.text('Infraestrutura'), findsWidgets); 
    });
  });
}