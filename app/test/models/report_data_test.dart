import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/report_data.dart';

void main() {
  group('ReportData Model Tests', () {
    test('Should create a ReportData instance with default empty values', () {
      // REMOVIDO O 'const' DAQUI
      final report = ReportData(category: 'Infraestrutura');

      expect(report.category, 'Infraestrutura');
      expect(report.title, '');
      expect(report.description, '');
      expect(report.photos, isEmpty);
      expect(report.latitude, isNull);
      expect(report.longitude, isNull);
    });

    test('Should correctly update fields using copyWith', () {
      // REMOVIDO O 'const' DAQUI
      final initialReport = ReportData(category: 'Infraestrutura');

      final updatedReport = initialReport.copyWith(
        title: 'Buraco',
        description: 'Estrada danificada',
        latitude: 41.15,
        longitude: -8.61,
      );

      expect(updatedReport.category, 'Infraestrutura');
      expect(updatedReport.title, 'Buraco');
      expect(updatedReport.description, 'Estrada danificada');
      expect(updatedReport.latitude, 41.15);
      expect(updatedReport.longitude, -8.61);
    });

    test(
      'Should clear latitude and longitude when clear flags are set to true in copyWith',
      () {
        // REMOVIDO O 'const' DAQUI
        final initialReport = ReportData(
          category: 'Infraestrutura',
          latitude: 41.15,
          longitude: -8.61,
        );

        final clearedReport = initialReport.copyWith(
          clearLatitude: true,
          clearLongitude: true,
        );

        expect(clearedReport.latitude, isNull);
        expect(clearedReport.longitude, isNull);
      },
    );
  });
}
