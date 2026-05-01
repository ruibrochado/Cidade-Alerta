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

void main() {
  group('IssueService Tests', () {
    late IssueService issueService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      registerFallbackValue(const <String, dynamic>{});

      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
      issueService = IssueService(client: mockSupabaseClient);
    });

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

        when(
          () => mockChain.inFilter(any(), any()),
        ).thenAnswer((_) => mockChain);

        // MISSING STUB ADDED HERE:
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
}
