import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/pages/confirm_report_page.dart';
import 'package:app/models/report_data.dart';

void main() {
  group('ConfirmPage Civic Integrity Tests', () {
    testWidgets('Renders civic data accurately before submission', (WidgetTester tester) async {
      const mockReport = ReportData(
        category: 'Iluminação Pública',
        title: 'Poste caido',
        description: 'Risco de choque elétrico',
        latitude: 38.7223,
        longitude: -9.1393,
        photos: [],
      );

      await tester.pumpWidget(const MaterialApp(
        home: ConfirmPage(report: mockReport),
      ));

      await tester.pumpAndSettle();

      expect(find.text('Confirmar Denúncia'), findsOneWidget);
      expect(find.text('Iluminação Pública'), findsOneWidget);
      expect(find.text('Poste caido'), findsOneWidget);
      expect(find.text('Risco de choque elétrico'), findsOneWidget);
      expect(find.text('Enviar Denúncia'), findsOneWidget);
    });

    testWidgets('Send button triggers loading state', (WidgetTester tester) async {
      const mockReport = ReportData(
        category: 'Lixo e Limpeza',
        title: 'Contentor a transbordar',
        description: 'Cheiro intenso',
        latitude: 41.1579,
        longitude: -8.6291,
        photos: [],
      );

      await tester.pumpWidget(const MaterialApp(
        home: ConfirmPage(report: mockReport),
      ));

      await tester.pumpAndSettle();

      final sendButton = find.text('Enviar Denúncia');
      await tester.tap(sendButton);
      await tester.pump();

      expect(find.text('Enviando...'), findsOneWidget);
    });
  });
}