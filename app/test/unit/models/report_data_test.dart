import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/report_data.dart';

void main() {
  group('ReportData Deep Unit Tests', () {
    test('Should handle missing fields by using default values', () {
      final Map<String, dynamic> minimalistMap = {
        'category': 'road',
      };

      final report = ReportData.fromMap(minimalistMap);

      expect(report.category, equals('road'));
      expect(report.title, equals(''));
      expect(report.photos, isEmpty);
      expect(report.latitude, isNull);
    });

    test('Should handle wrong data types gracefully (Type Safety)', () {
      final Map<String, dynamic> trickyMap = {
        'category': 'water',
        'latitude': 41,
        'longitude': -8,
      };

      final report = ReportData.fromMap(trickyMap);

      expect(report.latitude, isInstanceOf<double>());
      expect(report.latitude, equals(41.0));
    });

    test('Should handle null photo_url by returning an empty list', () {
      final Map<String, dynamic> mapWithNullPhoto = {
        'category': 'lights',
        'photo_url': null,
      };

      final report = ReportData.fromMap(mapWithNullPhoto);
      expect(report.photos, isEmpty);
    });

    test('copyWith should allow clearing coordinates (Extreme Case)', () {
      const originalReport = ReportData(
        category: 'road',
        latitude: 41.5,
        longitude: -8.4,
      );

      final updatedReport = originalReport.copyWith(clearLatitude: true);

      expect(updatedReport.latitude, isNull);
      expect(updatedReport.longitude, equals(-8.4));
    });

    test('EXTREME: Should handle emojis and special characters in title/description', () {
      final Map<String, dynamic> emojiMap = {
        'category': 'road',
        'title': '⚠️ Buraco Crítico! ⚠️',
        'description': 'Lixo acumulado 垃圾 e óleo no chão 🔥',
      };

      final report = ReportData.fromMap(emojiMap);
      expect(report.title, contains('⚠️'));
      expect(report.description, contains('垃圾'));
    });

    test('BOUNDARY: Should handle coordinate limits (Antarctica/Equator)', () {
      final Map<String, dynamic> southPole = {
        'category': 'other',
        'latitude': -90.0,
        'longitude': 0.0,
      };
      final report = ReportData.fromMap(southPole);
      expect(report.latitude, -90.0);
    });

    test('ROBUSTNESS: Should handle extremely long strings without crashing', () {
      final longString = 'D' * 10000;
      final report = ReportData(category: 'test', description: longString);
      expect(report.description.length, 10000);
    });
  });
}