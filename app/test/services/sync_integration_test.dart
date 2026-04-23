import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite/sqflite.dart';
import 'package:app/services/offline_service.dart';
import 'package:app/services/issue_service.dart';
import 'package:app/models/report_data.dart';

class MockDatabase extends Mock implements Database {}
class MockIssueService extends Mock implements IssueService {}

void main() {
  group('Sync Integration Logic (Mocked)', () {
    late OfflineService offlineService;
    late MockDatabase mockDb;
    late MockIssueService mockIssueService;

    setUp(() {
      mockDb = MockDatabase();
      mockIssueService = MockIssueService();
      offlineService = OfflineService(injectedDb: mockDb);
    });

    test('Should sync all local reports to Supabase and clean local DB', () async {
      final mockData = [
        {
          'id': 1,
          'data': '{"category":"Lixo","title":"Sync Test","description":"","photos":[],"latitude":1.0,"longitude":1.0,"address":null}',
        }
      ];

      when(() => mockDb.query('pending_reports')).thenAnswer((_) async => mockData);
      when(() => mockDb.delete(any(), where: any(named: 'where'), whereArgs: any(named: 'whereArgs')))
          .thenAnswer((_) async => 1);

      when(() => mockIssueService.createIssue(
        title: any(named: 'title'),
        description: any(named: 'description'),
        category: any(named: 'category'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        street: any(named: 'street'),
        photoPath: any(named: 'photoPath'),
      )).thenAnswer((_) async => 'TKT-123');

      final pending = await offlineService.getPendingReports();

      for (var item in pending) {
        final ReportData r = item['report'];
        await mockIssueService.createIssue(
          title: r.title,
          description: r.description,
          category: r.category,
          latitude: r.latitude ?? 0.0,
          longitude: r.longitude ?? 0.0,
          street: r.address,
        );
        await offlineService.deleteReport(item['db_id']);
      }

      verify(() => mockIssueService.createIssue(
        title: 'Sync Test',
        description: any(named: 'description'),
        category: any(named: 'category'),
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        street: any(named: 'street'),
      )).called(1);

      verify(() => mockDb.delete('pending_reports', where: 'id = ?', whereArgs: [1])).called(1);
    });
  });
}