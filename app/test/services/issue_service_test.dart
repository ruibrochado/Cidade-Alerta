import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/issue_service.dart';

// mock creation
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockUser extends Mock implements User {}

void main() {
  group('IssueService Tests', () {
    late IssueService issueService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;

    //sets up a clean environment before each test
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

        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('User not logged in'))),
      );
    });
    test('The system should catch issue creating errors (createIssue)', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('johndoe');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      // We force the DB servers to be down
      when(() => mockSupabaseClient.from('issues'))
          .thenThrow(Exception('Supabase Servers are down'));

      expect(
        () => issueService.createIssue(
          title: 'Buraco na Estrada',
          description: 'Buraco muito fundo e perigoso',
          category: 'Infraestrutura',
          latitude: 41.18,
          longitude: -8.60,
        ),
        
        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Error creating issue:'))),
      );
    });
    // Sad path
    test('The system should catch issue fetching errors (fetchIssue)', () async {
      when(() => mockSupabaseClient.from('issues'))
          .thenThrow(Exception('Supabase Servers are down'));

      expect(
        () => issueService.fetchIssues(),

        throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Error fetching issues:'))),
      );
    });

    // Happy path
    test('The system should return an empty list when there are no issues', () async {
      // TO:DO
      
      expect(true, isTrue, reason: 'Placeholder');
    });
  });
}