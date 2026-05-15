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

class _ExplodingFilterBuilder extends Fake
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  @override
  _ExplodingFilterBuilder eq(String column, Object value) => this;

  @override
  _ExplodingFilterBuilder neq(String column, Object value) => this;

  @override
  _ExplodingFilterBuilder order(
    String column, {
    bool ascending = true,
    bool nullsFirst = false,
    String? referencedTable,
  }) => this;

  @override
  _ExplodingFilterBuilder limit(int count, {String? referencedTable}) => this;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) => Future<List<Map<String, dynamic>>>.error(
    Exception('Erro de ligação à base de dados'),
  ).then(onValue, onError: onError);
}

void main() {
  group('IssueService.fetchUserActivity — Testes Unitários', () {
    late IssueService issueService;
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late MockSupabaseQueryBuilder mockQueryBuilder;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();

      when(() => mockClient.auth).thenReturn(mockAuth);

      issueService = IssueService(client: mockClient);
    });

    test(
      'devolve [] sem chamar a BD quando o utilizador não está autenticado',
      () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await issueService.fetchUserActivity();

        expect(result, isEmpty);
        verifyNever(() => mockClient.from(any()));
      },
    );

    test('devolve [] quando a base de dados lança uma Exception', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('user-abc');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final explodingBuilder = _ExplodingFilterBuilder();

      when(
        () => mockClient.from('comments'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.select(any()),
      ).thenAnswer((_) => explodingBuilder);

      final result = await issueService.fetchUserActivity();

      expect(result, isEmpty);
    });
  });
}
