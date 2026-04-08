import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/issue_category_page.dart'; 
import 'package:app/pages/details_page.dart';

void main() {
  group('SelectCategory UI Tests', () {
    
    // loads the App before each iteration
    Future<void> setupPage(WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SelectCategory(),
        ),
      );
    }

    testWidgets('Should render the headers and exactly 6 category buttons', (WidgetTester tester) async {
      
      await setupPage(tester);

      expect(find.text('Criar Denúncia'), findsOneWidget);
      expect(find.text('Selecione a categoria da sua denúncia'), findsOneWidget);

      expect(find.text('Infraestrutura'), findsOneWidget);
      expect(find.text('Iluminação Pública'), findsOneWidget);
      expect(find.text('Meio Ambiente'), findsOneWidget);

      //we use this gridview to check if the 6 categories are there, 
      //otherwise it would count the "voltar" button aswell
      final gridFinder = find.byType(GridView);
      final categoryButtons = find.descendant(
        of: gridFinder,
        matching: find.byType(InkWell),
      );

      expect(categoryButtons, findsNWidgets(6));
    });

    testWidgets('Should navigate to Details Page and pass the correct category when tapped', (WidgetTester tester) async {
      
      await setupPage(tester);

      final categoryButton = find.text('Infraestrutura');
      await tester.tap(categoryButton);

      await tester.pumpAndSettle();

      expect(find.byType(DetailsPage), findsOneWidget);

      expect(find.text('Descrever Problema'), findsOneWidget);
      
      expect(find.text('Infraestrutura'), findsWidgets); 
    });

  });
}