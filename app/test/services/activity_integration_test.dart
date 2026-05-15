import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/issue_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

// ignore: must_be_immutable
class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  List<Map<String, dynamic>> _data = [];
  void respondWith(List<Map<String, dynamic>> data) => _data = data;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) => Future.value(_data).then(onValue, onError: onError);
}

void main() {
  group('IssueService.fetchUserActivity — Testes de Integração', () {
    late IssueService issueService;
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late MockUser mockUser;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockUser = MockUser();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockUser.id).thenReturn('owner-123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      issueService = IssueService(client: mockClient);

      when(
        () => mockClient.from('comments'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.select(any()),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.eq(any(), any()),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.neq(any(), any()),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () =>
            mockFilterBuilder.order(any(), ascending: any(named: 'ascending')),
      ).thenAnswer((_) => mockFilterBuilder);

      when(
        () => mockFilterBuilder.limit(any()),
      ).thenAnswer((_) => mockFilterBuilder);
    });

    test(
      'query usa os filtros corretos: eq no user_id do issue, neq no próprio user',
      () async {
        mockFilterBuilder.respondWith([]);

        await issueService.fetchUserActivity();

        verify(
          () => mockFilterBuilder.eq('issues.user_id', 'owner-123'),
        ).called(1);

        verify(() => mockFilterBuilder.neq('user_id', 'owner-123')).called(1);

        verify(
          () => mockFilterBuilder.order('created_at', ascending: false),
        ).called(1);

        verify(() => mockFilterBuilder.limit(20)).called(1);
      },
    );

    test('mapeia corretamente o JSON aninhado com profiles e issues', () async {
      mockFilterBuilder.respondWith([
        {
          'id': 'comment-1',
          'content': 'Óptima denúncia, apoio!',
          'created_at': '2026-05-15T10:30:00Z',
          'user_id': 'commenter-456',
          'is_read': false,
          'issues': {
            'id': 'issue-789',
            'title': 'Buraco na estrada',
            'user_id': 'owner-123',
          },
          'profiles': {
            'first_name': 'Ana',
            'last_name': 'Silva',
            'profile_photo': 'https://example.com/ana.jpg',
          },
        },
      ]);

      final result = await issueService.fetchUserActivity();

      expect(result.length, 1);

      final profile = result[0]['profiles'] as Map<String, dynamic>;
      expect(profile['first_name'], 'Ana');
      expect(profile['last_name'], 'Silva');

      final issue = result[0]['issues'] as Map<String, dynamic>;
      expect(issue['title'], 'Buraco na estrada');
      expect(issue['id'], 'issue-789');

      expect(result[0]['content'], 'Óptima denúncia, apoio!');
      expect(result[0]['is_read'], false);
    });

    test('devolve lista vazia quando não há atividade recente', () async {
      mockFilterBuilder.respondWith([]);

      final result = await issueService.fetchUserActivity();

      expect(result, isEmpty);
    });

    test('devolve múltiplas atividades ordenadas corretamente', () async {
      mockFilterBuilder.respondWith([
        {
          'id': 'comment-1',
          'content': 'Primeiro comentário',
          'created_at': '2026-05-15T12:00:00Z',
          'user_id': 'commenter-A',
          'is_read': false,
          'issues': {
            'id': 'issue-1',
            'title': 'Lixo na rua',
            'user_id': 'owner-123',
          },
          'profiles': {
            'first_name': 'João',
            'last_name': 'Costa',
            'profile_photo': null,
          },
        },
        {
          'id': 'comment-2',
          'content': 'Segundo comentário',
          'created_at': '2026-05-14T08:00:00Z',
          'user_id': 'commenter-B',
          'is_read': true,
          'issues': {
            'id': 'issue-2',
            'title': 'Semáforo avariado',
            'user_id': 'owner-123',
          },
          'profiles': {
            'first_name': 'Maria',
            'last_name': 'Ferreira',
            'profile_photo': null,
          },
        },
      ]);

      final result = await issueService.fetchUserActivity();

      expect(result.length, 2);
      expect(result[0]['id'], 'comment-1');
      expect(result[1]['id'], 'comment-2');

      final profile0 = result[0]['profiles'] as Map<String, dynamic>;
      final profile1 = result[1]['profiles'] as Map<String, dynamic>;
      expect(profile0['first_name'], 'João');
      expect(profile1['first_name'], 'Maria');
    });
  });
}
