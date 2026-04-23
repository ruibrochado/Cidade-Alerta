import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/issue_category_page.dart';

void main() {
  group('Category Selection UI Tests', () {
    testWidgets('All mandatory municipal categories are present', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: SelectCategory(),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Infraestrutura'), findsOneWidget);
      expect(find.text('Iluminação Pública'), findsOneWidget);
      expect(find.text('Sinalização'), findsOneWidget);
      expect(find.text('Meio Ambiente'), findsOneWidget);
      expect(find.text('Lixo e Limpeza'), findsOneWidget);
      expect(find.text('Outros'), findsOneWidget);
    });
  });
}