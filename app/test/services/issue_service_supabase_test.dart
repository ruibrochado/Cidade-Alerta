import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/issue_service.dart';

class InMemoryStorage extends LocalStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<String?> accessToken() async => _storage['access_token'];

  @override
  Future<bool> hasAccessToken() async => _storage.containsKey('access_token');

  @override
  Future<void> persistSession(String persistSessionString) async =>
      _storage['access_token'] = persistSessionString;

  @override
  Future<void> removePersistedSession() async => _storage.clear();
}

const String _supabaseUrl = 'https://vvylvxymbwktociregtz.supabase.co';
const String _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ2eWx2eHltYndrdG9jaXJlZ3R6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ1NDY0MzcsImV4cCI6MjA5MDEyMjQzN30.sFzzVarsQ1WxoV2JfzyEW54s9tlimvqOEBMYj72t2rc';

const String _testEmail = 'joao@cmporto.com';
const String _testPassword = 'joaosousa';

void main() {
  late SupabaseClient supabase;
  late IssueService issueService;
  String? createdIssueId;

  setUpAll(() async {
    supabase = SupabaseClient(_supabaseUrl, _supabaseAnonKey);
    await supabase.auth.signInWithPassword(
      email: _testEmail,
      password: _testPassword,
    );
    issueService = IssueService(client: supabase);
  });

  tearDownAll(() async {
    final id = createdIssueId;
    if (id != null) {
      await supabase.from('issues').delete().eq('id', id);
    }
    await supabase.auth.signOut();
  });

  group('IssueService — Integration Tests (Real Supabase)', () {
    test('fetchIssues returns a real list of issues', () async {
      final results = await issueService.fetchIssues();

      expect(results, isA<List<Map<String, dynamic>>>());
      expect(results.length, lessThanOrEqualTo(IssueService.pageSize));

      if (results.isNotEmpty) {
        final first = results.first;
        expect(first.containsKey('id'), true);
        expect(first.containsKey('title'), true);
        expect(first.containsKey('status'), true);
      }
    });

    test('fetchIssuesCount returns the real number of issues', () async {
      final count = await issueService.fetchIssuesCount();
      expect(count, greaterThanOrEqualTo(0));
    });

    test('fetchIssues with searchQuery filters results correctly', () async {
      final results = await issueService.fetchIssues(
        searchQuery: 'zzzznonexistent',
      );
      expect(results, isEmpty);
    });

    test('updateIssueStatus updates the status in the real DB', () async {
      final issues = await issueService.fetchIssues(sortMode: 'top');
      expect(issues, isNotEmpty, reason: 'Needs at least one issue in the DB');

      final issueId = issues.first['id'] as String;
      final originalStatus = issues.first['status'] as String;

      final updatedStatus = await issueService.updateIssueStatus(
        issueId: issueId,
        status: 'in_progress',
      );
      expect(updatedStatus, 'in_progress');

      await issueService.updateIssueStatus(
        issueId: issueId,
        status: originalStatus,
      );
    });

    test(
      'fetchUserActivity returns real activity for the logged-in user',
      () async {
        final activity = await issueService.fetchUserActivity();
        expect(activity, isA<List<Map<String, dynamic>>>());

        if (activity.isNotEmpty) {
          final first = activity.first;
          expect(first.containsKey('id'), true);
          expect(first.containsKey('content'), true);
          expect(first.containsKey('issues'), true);
          expect(first.containsKey('profiles'), true);
        }
      },
    );

    test(
      'fetchMunicipalityReports returns issues from the correct city',
      () async {
        final results = await issueService.fetchMunicipalityReports(
          municipalityCity: 'Porto',
        );

        expect(results, isA<List<Map<String, dynamic>>>());

        for (final issue in results) {
          final city = (issue['city'] as String? ?? '').toLowerCase();
          expect(city, contains('porto'));
        }
      },
    );

    test('addComment and fetchComments work together correctly', () async {
      final issues = await issueService.fetchIssues(sortMode: 'top');
      expect(issues, isNotEmpty, reason: 'Needs at least one issue in the DB');

      final issueId = issues.first['id'] as String;
      const testComment = 'Integration test comment';

      await issueService.addComment(issueId, testComment);

      final comments = await issueService.fetchComments(issueId);
      expect(comments, isNotEmpty);

      final added = comments.any((c) => c['content'] == testComment);
      expect(added, true);

      await supabase
          .from('comments')
          .delete()
          .eq('issue_id', issueId)
          .eq('content', testComment);
    });
  });
}
