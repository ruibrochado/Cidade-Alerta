import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/issue_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilderList extends Mock
    implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {}

class MockPostgrestTransformBuilderSingle extends Mock
    implements PostgrestTransformBuilder<Map<String, dynamic>> {
  @override
  Future<R> then<R>(
    FutureOr<R> Function(Map<String, dynamic>) onValue, {
    Function? onError,
  }) {
    return Future.value({
      'id': 'issue-555',
      'ticket_number': 'TKT-202611-9999',
    }).then(onValue, onError: onError);
  }
}

class FakeFileOptions extends Fake implements FileOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(File('dummy.txt'));
    registerFallbackValue(FakeFileOptions());
  });

  group('IssueService Integration Tests', () {
    late IssueService issueService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late MockSupabaseStorageClient mockStorageClient;
    late MockStorageFileApi mockStorageFileApi;
    late MockFunctionsClient mockFunctionsClient;
    late MockSupabaseQueryBuilder mockQueryBuilder;
    late MockPostgrestFilterBuilder mockFilterBuilder;
    late MockPostgrestTransformBuilderList mockTransformList;
    late MockPostgrestTransformBuilderSingle mockTransformSingle;
    late File tempPhotoFile;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockStorageClient = MockSupabaseStorageClient();
      mockStorageFileApi = MockStorageFileApi();
      mockFunctionsClient = MockFunctionsClient();
      mockQueryBuilder = MockSupabaseQueryBuilder();
      mockFilterBuilder = MockPostgrestFilterBuilder();
      mockTransformList = MockPostgrestTransformBuilderList();
      mockTransformSingle = MockPostgrestTransformBuilderSingle();

      // Mocks de Base (Estes não são Futures, logo o thenReturn é seguro)
      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
      when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
      when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);
      when(
        () => mockStorageClient.from('issue-images'),
      ).thenReturn(mockStorageFileApi);

      issueService = IssueService(client: mockSupabaseClient);

      // Criação de ficheiro temporário para não falhar operações de I/O
      tempPhotoFile = File('temp_integration_photo.jpg');
      tempPhotoFile.writeAsBytesSync([0, 1, 2, 3]);
    });

    tearDown(() {
      // Limpeza da memória nativa
      if (tempPhotoFile.existsSync()) {
        tempPhotoFile.deleteSync();
      }
    });

    test('Full Workflow: Upload Photo -> Insert DB -> Trigger Edge Function', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('citizen-123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      when(
        () => mockStorageFileApi.upload(
          any(),
          any(),
          fileOptions: any(named: 'fileOptions'),
        ),
      ).thenAnswer((_) async => 'citizen-123/photo.jpg');

      when(
        () => mockStorageFileApi.getPublicUrl(any()),
      ).thenReturn('https://supabase.com/public/photo.jpg');

      // FIX CRÍTICO: Todas as operações de query usam thenAnswer agora.
      when(() => mockSupabaseClient.from('issues')).thenAnswer((_) => mockQueryBuilder);

      when(() => mockQueryBuilder.insert(any())).thenAnswer((_) => mockFilterBuilder);

      when(() => mockFilterBuilder.select(any())).thenAnswer((_) => mockTransformList);

      when(() => mockTransformList.single()).thenAnswer((_) => mockTransformSingle);

      final mockFunctionResponse = FunctionResponse(data: 'ok', status: 200);
      when(
        () => mockFunctionsClient.invoke(
          'forward-issue-to-municipality',
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => mockFunctionResponse);

      final ticket = await issueService.createIssue(
        title: 'Estrada Abatida',
        description: 'Cratera na faixa da direita.',
        category: 'Infraestrutura',
        latitude: 41.1496,
        longitude: -8.6109,
        street: 'Avenida dos Aliados',
        photoPath: tempPhotoFile.path,
      );

      // Validações
      expect(ticket, 'TKT-202611-9999');

      verify(() => mockStorageFileApi.upload(any(), any(), fileOptions: any(named: 'fileOptions'))).called(1);

      verify(
        () => mockQueryBuilder.insert(
          any(
            that: isA<Map<String, dynamic>>().having(
              (m) => m['photo_url'],
              'photo_url',
              'https://supabase.com/public/photo.jpg',
            ),
          ),
        ),
      ).called(1);

      verify(
        () => mockFunctionsClient.invoke(
          'forward-issue-to-municipality',
          body: {'issue_id': 'issue-555'},
        ),
      ).called(1);
    });
  });
}