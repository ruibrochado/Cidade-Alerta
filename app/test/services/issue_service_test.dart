import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/issue_service.dart';

// --- Core Mocks ---
class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

// --- Supabase Query Chain Mocks --- (for the Happy path)
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

// We hardcode the Future resolution directly into the class.
// This blocks Mocktail from returning 'null' when Dart calls 'await'.
class MockPostgrestTransformBuilder extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
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

      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);

      issueService = IssueService(client: mockSupabaseClient);
    });

    test('The report should be stopped if the user isnt logged in', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => issueService.createIssue(
          title: 'Buraco na Estrada',
          description: 'Buraco muito fundo e perigoso',
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

    test(
      'The system should catch issue creating errors (createIssue)',
      () async {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('johndoe');
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        when(
          () => mockSupabaseClient.from('issues'),
        ).thenThrow(Exception('Supabase Servers are down'));

        expect(
          () => issueService.createIssue(
            title: 'Buraco na Estrada',
            description: 'Buraco muito fundo e perigoso',
            category: 'Infraestrutura',
            latitude: 41.18,
            longitude: -8.60,
          ),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error creating issue:'),
            ),
          ),
        );
      },
    );

    test(
      'The system should catch issue fetching errors (fetchIssue)',
      () async {
        when(
          () => mockSupabaseClient.from('issues'),
        ).thenThrow(Exception('Supabase Servers are down'));

        expect(
          () => issueService.fetchIssues(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error fetching issues:'),
            ),
          ),
        );
      },
    );

    test(
      'The system should return an empty list when there are no issues',
      () async {
        final mockQueryBuilder = MockSupabaseQueryBuilder();
        final mockFilterBuilder = MockPostgrestFilterBuilder();
        final mockTransformBuilder = MockPostgrestTransformBuilder();

        // Return the builders down the chain
        when(
          () => mockSupabaseClient.from('issues'),
        ).thenAnswer((_) => mockQueryBuilder);
        when(
          () => mockQueryBuilder.select(),
        ).thenAnswer((_) => mockFilterBuilder);
        when(
          () => mockFilterBuilder.order(
            'created_at',
            ascending: any(named: 'ascending'),
          ),
        ).thenAnswer((_) => mockTransformBuilder);

        final results = await issueService.fetchIssues();

        expect(results, isEmpty);
        expect(results, isA<List<Map<String, dynamic>>>());
      },
    );
  });
}
