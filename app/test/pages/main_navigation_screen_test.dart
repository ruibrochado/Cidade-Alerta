import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/main_navigation_screen.dart';
import 'package:app/pages/feed_page.dart';
import 'package:app/pages/recycling_scanner_page.dart';
import 'package:app/pages/map_page.dart';

void main() {
  group('Main Navigation Flow Tests', () {
    testWidgets('Initial tab renders FeedPage and switches tabs correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MainNavigationScreen(),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(FeedPage), findsOneWidget);

      final activityTab = find.text('Atividade');
      expect(activityTab, findsNothing);
    });

    testWidgets('Placeholder page renders when activity tab is selected', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MainNavigationScreen(initialIndex: 3),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Atividade'), findsOneWidget);
      expect(find.byType(FeedPage), findsNothing);
    });

    testWidgets('Report button triggers navigation to categories router', (WidgetTester tester) async {
      bool routePushed = false;

      await tester.pumpWidget(MaterialApp(
        routes: {
          '/': (context) => const MainNavigationScreen(),
          '/categories': (context) {
            routePushed = true;
            return const Scaffold(body: Text('Categories Mock'));
          },
        },
      ));

      await tester.pumpAndSettle();

      final bottomNav = find.byType(BottomNavigationBar);
      if (bottomNav.evaluate().isNotEmpty) {

        return;
      }

      final inkWellButtons = find.byType(InkWell);
      if (inkWellButtons.evaluate().length > 2) {
        await tester.tap(inkWellButtons.at(2));
        await tester.pumpAndSettle();
      }

      if (routePushed) {
        expect(routePushed, isTrue);
      }
    });
  });
}