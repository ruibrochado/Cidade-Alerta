import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/profile_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder<T> extends Mock
    implements PostgrestFilterBuilder<T> {
  final T _data;
  MockPostgrestFilterBuilder(this._data);

  @override
  Future<R> then<R>(FutureOr<R> Function(T) onValue, {Function? onError}) =>
      Future.value(_data).then(onValue, onError: onError);
}

class MockPostgrestTransformBuilderSingle extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>?> {
  final Map<String, dynamic>? _data;
  MockPostgrestTransformBuilderSingle(this._data);

  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic>?) onValue, {
    Function? onError,
  }) => Future.value(_data).then(onValue, onError: onError);
}

void main() {
  group('ProfileService — Testes de Integração', () {
    late ProfileService profileService;
    late MockSupabaseClient mockClient;
    late MockGoTrueClient mockAuth;
    late MockUser mockUser;
    late MockFunctionsClient mockFunctions;

    setUp(() {
      mockClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockUser = MockUser();
      mockFunctions = MockFunctionsClient();

      when(() => mockClient.auth).thenReturn(mockAuth);
      when(() => mockClient.functions).thenReturn(mockFunctions);
      when(() => mockUser.id).thenReturn('user-123');
      when(() => mockUser.email).thenReturn('test@example.com');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      profileService = ProfileService(client: mockClient);
    });

    group('loadProfile', () {
      test(
        'devolve dados padrão quando utilizador não está autenticado',
        () async {
          when(() => mockAuth.currentUser).thenReturn(null);

          final result = await profileService.loadProfile();

          expect(result['name'], 'Utilizador');
          expect(result['email'], 'sem email');
          expect(result['reportedIssuesCount'], 0);
          expect(result['votedIssuesCount'], 0);
          verifyNever(() => mockClient.from(any()));
        },
      );

      test('devolve contagens corretas de denúncias e votos', () async {
        final issuesQueryBuilder = MockSupabaseQueryBuilder();
        final votesQueryBuilder = MockSupabaseQueryBuilder();
        final profilesQueryBuilder = MockSupabaseQueryBuilder();

        final issuesFilter =
            MockPostgrestFilterBuilder<List<Map<String, dynamic>>>([
              {'id': '1'},
              {'id': '2'},
              {'id': '3'},
            ]);
        final votesFilter =
            MockPostgrestFilterBuilder<List<Map<String, dynamic>>>([
              {'id': 'v1'},
              {'id': 'v2'},
            ]);
        final profilesFilter =
            MockPostgrestFilterBuilder<List<Map<String, dynamic>>>([]);
        final profilesSingle = MockPostgrestTransformBuilderSingle({
          'first_name': 'Ricardo',
          'last_name': 'Silva',
          'profile_photo': null,
        });

        when(
          () => mockClient.from('issues'),
        ).thenAnswer((_) => issuesQueryBuilder);
        when(
          () => issuesQueryBuilder.select(any()),
        ).thenAnswer((_) => issuesFilter);
        when(
          () => issuesFilter.eq(any(), any()),
        ).thenAnswer((_) => issuesFilter);

        when(
          () => mockClient.from('issue_votes'),
        ).thenAnswer((_) => votesQueryBuilder);
        when(
          () => votesQueryBuilder.select(any()),
        ).thenAnswer((_) => votesFilter);
        when(() => votesFilter.eq(any(), any())).thenAnswer((_) => votesFilter);

        when(
          () => mockClient.from('profiles'),
        ).thenAnswer((_) => profilesQueryBuilder);
        when(
          () => profilesQueryBuilder.select(any()),
        ).thenAnswer((_) => profilesFilter);
        when(
          () => profilesFilter.eq(any(), any()),
        ).thenAnswer((_) => profilesFilter);
        when(
          () => profilesFilter.maybeSingle(),
        ).thenAnswer((_) => profilesSingle);

        final result = await profileService.loadProfile();

        expect(result['reportedIssuesCount'], 3);
        expect(result['votedIssuesCount'], 2);
        expect(result['name'], 'Ricardo Silva');
        expect(result['email'], 'test@example.com');
      });

      test('constrói nome completo corretamente a partir do perfil', () async {
        final issuesQueryBuilder = MockSupabaseQueryBuilder();
        final votesQueryBuilder = MockSupabaseQueryBuilder();
        final profilesQueryBuilder = MockSupabaseQueryBuilder();

        final emptyFilter =
            MockPostgrestFilterBuilder<List<Map<String, dynamic>>>([]);
        final profilesFilter =
            MockPostgrestFilterBuilder<List<Map<String, dynamic>>>([]);
        final profilesSingle = MockPostgrestTransformBuilderSingle({
          'first_name': 'Ana',
          'last_name': 'Costa',
          'profile_photo': 'https://example.com/ana.jpg',
        });

        when(
          () => mockClient.from('issues'),
        ).thenAnswer((_) => issuesQueryBuilder);
        when(
          () => issuesQueryBuilder.select(any()),
        ).thenAnswer((_) => emptyFilter);
        when(() => emptyFilter.eq(any(), any())).thenAnswer((_) => emptyFilter);

        when(
          () => mockClient.from('issue_votes'),
        ).thenAnswer((_) => votesQueryBuilder);
        when(
          () => votesQueryBuilder.select(any()),
        ).thenAnswer((_) => emptyFilter);

        when(
          () => mockClient.from('profiles'),
        ).thenAnswer((_) => profilesQueryBuilder);
        when(
          () => profilesQueryBuilder.select(any()),
        ).thenAnswer((_) => profilesFilter);
        when(
          () => profilesFilter.eq(any(), any()),
        ).thenAnswer((_) => profilesFilter);
        when(
          () => profilesFilter.maybeSingle(),
        ).thenAnswer((_) => profilesSingle);

        final result = await profileService.loadProfile();

        expect(result['name'], 'Ana Costa');
        expect(result['profilePhotoUrl'], 'https://example.com/ana.jpg');
      });
    });

    group('deleteAccount', () {
      test('invoca a Edge Function delete-user e faz signOut', () async {
        when(
          () => mockFunctions.invoke('delete-user'),
        ).thenAnswer((_) async => FunctionResponse(data: 'ok', status: 200));

        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        await profileService.deleteAccount();

        verify(() => mockFunctions.invoke('delete-user')).called(1);
        verify(() => mockAuth.signOut()).called(1);
      });

      test('signOut não é chamado se a Edge Function falhar', () async {
        when(
          () => mockFunctions.invoke('delete-user'),
        ).thenThrow(Exception('Erro no servidor'));

        expect(() => profileService.deleteAccount(), throwsException);

        verifyNever(() => mockAuth.signOut());
      });
    });

    group('logout', () {
      test('chama signOut corretamente', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        await profileService.logout();

        verify(() => mockAuth.signOut()).called(1);
      });
    });
  });
}
