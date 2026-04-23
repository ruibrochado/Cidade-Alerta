import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/auth_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockAuthResponse extends Mock implements AuthResponse {}
class MockUser extends Mock implements User {}
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}
class MockPostgrestFilterBuilder extends Mock implements PostgrestFilterBuilder {}

void main() {
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockAuth;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockAuth = MockGoTrueClient();
    when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
    authService = AuthService(client: mockSupabaseClient);
  });

  group('AuthService Integration & Unit Tests', () {
    test('SIGN IN: Should call Supabase signIn with correct credentials', () async {
      final mockResponse = MockAuthResponse();
      when(() => mockAuth.signInWithPassword(
        email: 'teste@cidadealerta.pt',
        password: 'password123',
      )).thenAnswer((_) async => mockResponse);

      await authService.signIn('teste@cidadealerta.pt', 'password123');

      verify(() => mockAuth.signInWithPassword(
        email: 'teste@cidadealerta.pt',
        password: 'password123',
      )).called(1);
    });

    test('SIGN UP: Should call Supabase signUp and pass user metadata', () async {
      final mockResponse = MockAuthResponse();

      when(() => mockAuth.signUp(
        email: 'novo@teste.pt',
        password: 'password123',
        data: any(named: 'data'),
      )).thenAnswer((_) async => mockResponse);

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.upsert(any())).thenReturn(mockFilterBuilder);

      await authService.signUp('João', 'Silva', 'novo@teste.pt', 'password123');

      verify(() => mockAuth.signUp(
        email: 'novo@teste.pt',
        password: 'password123',
        data: {
          'first_name': 'João',
          'last_name': 'Silva',
        },
      )).called(1);
    });

    test('INTEGRATION: Should upsert profile data immediately after successful signup', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('uuid_123');
      final mockResponse = MockAuthResponse();
      when(() => mockResponse.user).thenReturn(mockUser);

      when(() => mockAuth.signUp(
        email: 'test@test.pt',
        password: 'password',
        data: any(named: 'data'),
      )).thenAnswer((_) async => mockResponse);

      final mockQueryBuilder = MockSupabaseQueryBuilder();
      final mockFilterBuilder = MockPostgrestFilterBuilder();
      when(() => mockSupabaseClient.from('profiles')).thenReturn(mockQueryBuilder);
      when(() => mockQueryBuilder.upsert(any())).thenReturn(mockFilterBuilder);

      await authService.signUp('Ricardo', 'Alves', 'test@test.pt', 'password');

      verify(() => mockSupabaseClient.from('profiles')).called(1);
    });

    test('LOGOUT: Should call signOut and clear session', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async => {});
      await authService.signOut();
      verify(() => mockAuth.signOut()).called(1);
    });
  });
}