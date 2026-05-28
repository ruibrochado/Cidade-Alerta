import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/issue_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements
        PostgrestFilterBuilder<List<Map<String, dynamic>>>,
        PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) {
    return Future.value(
      <Map<String, dynamic>>[],
    ).then(onValue, onError: onError);
  }
}

class MockPostgrestSingleBuilder extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  final Map<String, dynamic>? _data;
  MockPostgrestSingleBuilder(this._data);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic>?) onValue, {
    Function? onError,
  }) {
    return Future.value(_data).then(onValue, onError: onError);
  }
}

class MockPostgrestCountBuilder extends Mock
    implements
        ResponsePostgrestBuilder<
          PostgrestResponse<List<Map<String, dynamic>>>,
          List<Map<String, dynamic>>,
          List<Map<String, dynamic>>
        > {
  @override
  Future<R> then<R>(
    FutureOr<R> Function(PostgrestResponse<List<Map<String, dynamic>>>)
    onValue, {
    Function? onError,
  }) {
    return Future.value(
      const PostgrestResponse(data: <Map<String, dynamic>>[], count: 0),
    ).then(onValue, onError: onError);
  }
}

void main() {
  late IssueService issueService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;

  setUpAll(() {
    registerFallbackValue(CountOption.exact);
  });

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    registerFallbackValue(const <String, dynamic>{});

    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    issueService = IssueService(client: mockSupabaseClient);
  });

  group('IssueService Tests', () {
    test('The report should be stopped if the user isnt logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);
      expect(
        () => issueService.createIssue(
          title: 'Buraco',
          description: '...',
          category: 'Infraestrutura',
          latitude: 41.18,
          longitude: -8.60,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('User not logged in'),
          ),
        ),
      );
    });

    test('The system should catch issue creating errors', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('johndoe');
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(
        () => mockSupabaseClient.from('issues'),
      ).thenThrow(Exception('Servers down'));

      expect(
        () => issueService.createIssue(
          title: 'B',
          description: '...',
          category: 'Infraestrutura',
          latitude: 41.0,
          longitude: -8.0,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error creating issue'),
          ),
        ),
      );
    });

    test(
      'The system should return an empty list when there are no issues',
      () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockChain = MockPostgrestFilterBuilder();

        when(
          () => mockSupabaseClient.from('issues'),
        ).thenAnswer((_) => mockQueryBuilder);

        when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockChain);
        when(() => mockChain.eq(any(), any())).thenAnswer((_) => mockChain);
        when(() => mockChain.neq(any(), any())).thenAnswer((_) => mockChain);
        when(() => mockChain.ilike(any(), any())).thenAnswer((_) => mockChain);
        when(() => mockChain.or(any())).thenAnswer((_) => mockChain);
        when(
          () => mockChain.inFilter(any(), any()),
        ).thenAnswer((_) => mockChain);
        when(() => mockChain.gte(any(), any())).thenAnswer((_) => mockChain);
        when(
          () => mockChain.order(any(), ascending: any(named: 'ascending')),
        ).thenAnswer((_) => mockChain);
        when(() => mockChain.range(any(), any())).thenAnswer((_) => mockChain);

        final results = await issueService.fetchIssues();

        expect(results, isEmpty);
        expect(results, isA<List<Map<String, dynamic>>>());
      },
    );
  });

  group('IssueService Municipality Tests', () {
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockChain;

    setUp(() {
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockChain = MockPostgrestFilterBuilder();

      when(
        () => mockSupabaseClient.from(any()),
      ).thenAnswer((_) => mockQueryBuilder);
      when(() => mockQueryBuilder.select(any())).thenAnswer((_) => mockChain);
      when(() => mockQueryBuilder.update(any())).thenAnswer((_) => mockChain);
      when(() => mockQueryBuilder.delete()).thenAnswer((_) => mockChain);
      when(() => mockChain.select(any())).thenAnswer((_) => mockChain);
      when(() => mockChain.eq(any(), any())).thenAnswer((_) => mockChain);
      when(() => mockChain.neq(any(), any())).thenAnswer((_) => mockChain);
      when(() => mockChain.ilike(any(), any())).thenAnswer((_) => mockChain);
      when(
        () => mockChain.order(any(), ascending: any(named: 'ascending')),
      ).thenAnswer((_) => mockChain);
      when(() => mockChain.range(any(), any())).thenAnswer((_) => mockChain);
    });

    test('archiveIssue throws exception when issueId is empty', () async {
      expect(
        () => issueService.archiveIssue(''),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Invalid issue id'),
          ),
        ),
      );
    });

    test(
      'archiveIssue throws exception when issue is not found in DB',
      () async {
        when(
          () => mockChain.maybeSingle(),
        ).thenAnswer((_) => MockPostgrestSingleBuilder(null));

        expect(
          () => issueService.archiveIssue('nonexistent-id'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Issue not found'),
            ),
          ),
        );
      },
    );

    test(
      'updateIssueStatus throws exception when issue is not found in DB',
      () async {
        when(
          () => mockChain.maybeSingle(),
        ).thenAnswer((_) => MockPostgrestSingleBuilder(null));

        expect(
          () => issueService.updateIssueStatus(
            issueId: 'nonexistent-id',
            status: 'in_progress',
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Issue status was not updated'),
            ),
          ),
        );
      },
    );

    test('updateIssueStatus returns updated status on success', () async {
      when(() => mockChain.maybeSingle()).thenAnswer(
        (_) => MockPostgrestSingleBuilder({
          'id': 'issue-123',
          'status': 'in_progress',
        }),
      );

      final result = await issueService.updateIssueStatus(
        issueId: 'issue-123',
        status: 'in_progress',
      );

      expect(result, 'in_progress');
    });

    test(
      'fetchMunicipalityReportsCount returns 0 when no issues exist',
      () async {
        when(
          () => mockChain.count(any()),
        ).thenAnswer((_) => MockPostgrestCountBuilder());

        final count = await issueService.fetchMunicipalityReportsCount(
          municipalityCity: 'Porto',
        );

        expect(count, 0);
      },
    );
  });
}
