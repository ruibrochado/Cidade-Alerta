import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/auth_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  @override
  Future<R> then<R>(
    FutureOr<R> Function(List<Map<String, dynamic>>) onValue, {
    Function? onError,
  }) {
    return Future.value(<Map<String, dynamic>>[]).then(onValue, onError: onError);
  }
}

class MockUser extends Mock implements User {}

class MockAuthResponse extends Mock implements AuthResponse {}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockPostgrestFilterBuilder;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockPostgrestFilterBuilder = MockPostgrestFilterBuilder();

      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);

      authService = AuthService(client: mockSupabaseClient);
    });

    test('Should sign up user and create profile successfully', () async {
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();

      when(() => mockUser.id).thenReturn('12345');
      when(() => mockResponse.user).thenReturn(mockUser);

      when(
        () => mockAuth.signUp(
          email: 'test@email.com',
          password: 'password123',
          data: {'first_name': 'João', 'last_name': 'Silva'},
        ),
      ).thenAnswer((_) async => mockResponse);

      when(
        () => mockSupabaseClient.from('profiles'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.upsert({
          'id': '12345',
          'first_name': 'João',
          'last_name': 'Silva',
        }),
      ).thenAnswer((_) => mockPostgrestFilterBuilder);

      final result = await authService.signUp(
        'João',
        'Silva',
        'test@email.com',
        'password123',
      );

      expect(result, equals(mockResponse));
      verify(() => mockSupabaseClient.from('profiles')).called(1);
    });

    test('Should sign up successfully but not call upsert if user is null', () async {
      final mockResponse = MockAuthResponse();

      when(() => mockResponse.user).thenReturn(null);

      when(
        () => mockAuth.signUp(
          email: 'test@email.com',
          password: 'password123',
          data: {'first_name': 'Ana', 'last_name': 'Costa'},
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await authService.signUp(
        'Ana',
        'Costa',
        'test@email.com',
        'password123',
      );

      expect(result, equals(mockResponse));
      verifyNever(() => mockSupabaseClient.from('profiles'));
    });

    test('Should throw exception when signUp fails', () async {
      when(
        () => mockAuth.signUp(
          email: 'test@email.com',
          password: 'password123',
          data: {'first_name': 'Rui', 'last_name': 'Santos'},
        ),
      ).thenThrow(Exception('Network error'));

      expect(
        () => authService.signUp(
          'Rui',
          'Santos',
          'test@email.com',
          'password123',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error signing up:'),
          ),
        ),
      );
    });

    test('Should throw exception when profile upsert fails', () async {
      final mockUser = MockUser();
      final mockResponse = MockAuthResponse();

      when(() => mockUser.id).thenReturn('67890');
      when(() => mockResponse.user).thenReturn(mockUser);

      when(
        () => mockAuth.signUp(
          email: 'test@email.com',
          password: 'password123',
          data: {'first_name': 'Nuno', 'last_name': 'Mendes'},
        ),
      ).thenAnswer((_) async => mockResponse);

      when(
        () => mockSupabaseClient.from('profiles'),
      ).thenAnswer((_) => mockQueryBuilder);

      when(
        () => mockQueryBuilder.upsert({
          'id': '67890',
          'first_name': 'Nuno',
          'last_name': 'Mendes',
        }),
      ).thenThrow(Exception('Database down'));

      expect(
        () => authService.signUp(
          'Nuno',
          'Mendes',
          'test@email.com',
          'password123',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error signing up:'),
          ),
        ),
      );
    });

    test('Should sign in user successfully', () async {
      final mockResponse = MockAuthResponse();

      when(
        () => mockAuth.signInWithPassword(
          email: 'test@email.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockResponse);

      final result = await authService.signIn(
        'test@email.com',
        'password123',
      );

      expect(result, equals(mockResponse));
    });

    test('Should throw exception when signIn fails', () async {
      when(
        () => mockAuth.signInWithPassword(
          email: 'test@email.com',
          password: 'password123',
        ),
      ).thenThrow(Exception('Invalid credentials'));

      expect(
        () => authService.signIn('test@email.com', 'password123'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error signing in:'),
          ),
        ),
      );
    });

    test('Should sign out successfully', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });

    test('Should return current user', () {
      final mockUser = MockUser();
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final result = authService.getCurrentUser();

      expect(result, equals(mockUser));
    });

    test('Should return null if no user is logged in', () {
      when(() => mockAuth.currentUser).thenReturn(null);

      final result = authService.getCurrentUser();

      expect(result, isNull);
    });
  });
}