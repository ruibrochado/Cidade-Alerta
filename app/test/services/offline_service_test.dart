import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app/services/offline_service.dart';
import 'package:app/models/report_data.dart';

class MockDatabase extends Mock implements Database {}

void main() {
  group('OfflineService Unit Tests (Mocked)', () {
    late OfflineService offlineService;
    late MockDatabase mockDb;

    setUp(() {
      mockDb = MockDatabase();
      offlineService = OfflineService(injectedDb: mockDb);
    });

    test('Should save report to local database', () async {
      final report = ReportData(category: 'Lixo', title: 'Acumulação');

      when(
        () => mockDb.insert('pending_reports', any()),
      ).thenAnswer((_) async => 1);

      final id = await offlineService.saveReportOffline(report);

      expect(id, 1);
      verify(() => mockDb.insert('pending_reports', any())).called(1);
    });

    test('Should retrieve pending reports correctly', () async {
      final mockData = [
        {
          'id': 10,
          'data':
              '{"category":"Lixo","title":"Teste","description":"","photos":[],"latitude":1.0,"longitude":1.0,"address":null}',
          'created_at': '2026-01-01T00:00:00Z',
        },
      ];

      when(
        () => mockDb.query('pending_reports'),
      ).thenAnswer((_) async => mockData);

      final results = await offlineService.getPendingReports();

      expect(results.length, 1);
      expect(results.first['db_id'], 10);
      expect(results.first['report'].title, 'Teste');
    });

    test('Should delete report from local database', () async {
      when(
        () => mockDb.delete(
          'pending_reports',
          where: any(named: 'where'),
          whereArgs: any(named: 'whereArgs'),
        ),
      ).thenAnswer((_) async => 1);

      await offlineService.deleteReport(10);

      verify(
        () =>
            mockDb.delete('pending_reports', where: 'id = ?', whereArgs: [10]),
      ).called(1);
    });
  });
}
