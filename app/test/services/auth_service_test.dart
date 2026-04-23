import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/auth_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class FakePostgrestFilterBuilder extends Fake implements PostgrestFilterBuilder<dynamic> {
  @override
  Future<R> then<R>(FutureOr<R> Function(dynamic value) onValue, {Function? onError}) async {
    return onValue(<dynamic>[]);
  }
}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  late AuthService authService;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();

    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);

    authService = AuthService(client: mockSupabaseClient);
  });

  group('AuthService Security & Logic Tests', () {
    test('signIn returns AuthResponse on valid credentials', () async {
      final mockResponse = MockAuthResponse();
      when(() => mockGoTrueClient.signInWithPassword(
        email: 'citizen@portugal.pt',
        password: 'securePassword123',
      )).thenAnswer((_) async => mockResponse);

      final result = await authService.signIn('citizen@portugal.pt', 'securePassword123');

      expect(result, equals(mockResponse));
      verify(() => mockGoTrueClient.signInWithPassword(
        email: 'citizen@portugal.pt',
        password: 'securePassword123',
      )).called(1);
    });

    test('signIn throws Exception on invalid credentials', () async {
      when(() => mockGoTrueClient.signInWithPassword(
        email: 'hacker@invalid.com',
        password: 'wrongpassword',
      )).thenThrow(const AuthException('Invalid login credentials'));

      expect(
            () => authService.signIn('hacker@invalid.com', 'wrongpassword'),
        throwsA(isA<Exception>()),
      );
    });

    test('getCurrentUser returns authenticated User data', () {
      final mockUser = MockUser();
      when(() => mockGoTrueClient.currentUser).thenReturn(mockUser);

      final user = authService.getCurrentUser();

      expect(user, equals(mockUser));
    });

    test('getCurrentUser returns null when session is dead', () {
      when(() => mockGoTrueClient.currentUser).thenReturn(null);

      final user = authService.getCurrentUser();

      expect(user, isNull);
    });

    test('signOut terminates session successfully', () async {
      when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockGoTrueClient.signOut()).called(1);
    });

    test('signUp creates auth user and inserts profile data in database', () async {
      final mockResponse = MockAuthResponse();
      final mockUser = MockUser();
      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final fakeFilterBuilder = FakePostgrestFilterBuilder();

      when(() => mockUser.id).thenReturn('uuid-1234-5678');
      when(() => mockResponse.user).thenReturn(mockUser);

      when(() => mockGoTrueClient.signUp(
        email: 'novo@cidadao.pt',
        password: 'securePassword123',
        data: {'first_name': 'João', 'last_name': 'Silva'},
      )).thenAnswer((_) async => mockResponse);

      when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.upsert(any())).thenReturn(fakeFilterBuilder);

      final result = await authService.signUp(
        'João',
        'Silva',
        'novo@cidadao.pt',
        'securePassword123',
      );

      expect(result, equals(mockResponse));

      verify(() => mockGoTrueClient.signUp(
        email: 'novo@cidadao.pt',
        password: 'securePassword123',
        data: {'first_name': 'João', 'last_name': 'Silva'},
      )).called(1);

      verify(() => mockSupabaseClient.from('profiles')).called(1);
      verify(() => mockQueryBuilder.upsert({
        'id': 'uuid-1234-5678',
        'first_name': 'João',
        'last_name': 'Silva',
      })).called(1);
    });

    test('signUp throws Exception when API fails', () async {
      when(() => mockGoTrueClient.signUp(
        email: 'fail@cidadao.pt',
        password: 'weak',
        data: {'first_name': 'Erro', 'last_name': 'Teste'},
      )).thenThrow(const AuthException('Password too weak'));

      expect(
            () => authService.signUp('Erro', 'Teste', 'fail@cidadao.pt', 'weak'),
        throwsA(isA<Exception>()),
      );

      verifyNever(() => mockSupabaseClient.from('profiles'));
    });
  });
}