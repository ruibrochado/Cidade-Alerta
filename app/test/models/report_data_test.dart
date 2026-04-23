import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/report_data.dart';

void main() {
  group('ReportData Civic Integrity Tests', () {
    test('fromMap creates valid payload for municipality API', () {
      final payloadData = {
        'id': 'uuid-1234',
        'category': 'Infraestrutura',
        'title': 'Buraco na Via',
        'description': 'Risco grave',
        'photo_url': 'https://storage.supabase.com/photo.jpg',
        'latitude': 38.7223,
        'longitude': -9.1393,
        'address': 'Avenida da Liberdade, Lisboa',
        'score': 15,
      };

      final report = ReportData.fromMap(payloadData);

      expect(report.id, 'uuid-1234');
      expect(report.category, 'Infraestrutura');
      expect(report.photos, contains('https://storage.supabase.com/photo.jpg'));
      expect(report.latitude, 38.7223);
      expect(report.score, 15);
    });

    test('copyWith updates specific civic metrics while retaining others', () {
      const initialReport = ReportData(
        category: 'Iluminação',
        title: 'Lâmpada fundida',
        score: 0,
      );

      final updatedReport = initialReport.copyWith(score: 5, address: 'Rua do Ouro');

      expect(updatedReport.score, 5);
      expect(updatedReport.address, 'Rua do Ouro');
      expect(updatedReport.category, 'Iluminação');
    });
  });
}