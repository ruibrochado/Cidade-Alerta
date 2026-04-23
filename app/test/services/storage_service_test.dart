import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app/services/storage_service.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}

class MockStorageFileApi extends Mock implements StorageFileApi {}

class MockFile extends Mock implements File {}

void main() {
  setUpAll(() {
    registerFallbackValue(MockFile());
  });

  group('StorageService Tests', () {
    late StorageService storageService;
    late MockSupabaseClient mockSupabaseClient;
    late MockGoTrueClient mockAuth;
    late MockSupabaseStorageClient mockStorageClient;
    late MockStorageFileApi mockStorageFileApi;

    setUp(() {
      mockSupabaseClient = MockSupabaseClient();
      mockAuth = MockGoTrueClient();
      mockStorageClient = MockSupabaseStorageClient();
      mockStorageFileApi = MockStorageFileApi();

      when(() => mockSupabaseClient.auth).thenReturn(mockAuth);
      when(() => mockSupabaseClient.storage).thenReturn(mockStorageClient);
      when(
        () => mockStorageClient.from('issue-images'),
      ).thenReturn(mockStorageFileApi);

      storageService = StorageService(client: mockSupabaseClient);
    });

    test(
      'Should throw exception if user is not logged in during upload',
      () async {
        when(() => mockAuth.currentUser).thenReturn(null);
        final fakeFile = MockFile();

        expect(
          () => storageService.uploadIssueImage(fakeFile, 'photo.jpg'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('User not logged in'),
            ),
          ),
        );
      },
    );

    test('Should upload image successfully and return correct path', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('municipe123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final fakeFile = MockFile();
      final expectedPath = 'municipe123/photo.jpg';

      when(
        () => mockStorageFileApi.upload(expectedPath, any()),
      ).thenAnswer((_) async => expectedPath);

      final result = await storageService.uploadIssueImage(
        fakeFile,
        'photo.jpg',
      );

      expect(result, equals(expectedPath));
      verify(() => mockStorageFileApi.upload(expectedPath, fakeFile)).called(1);
    });

    test('Should throw exception when storage upload fails', () async {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('municipe123');
      when(() => mockAuth.currentUser).thenReturn(mockUser);

      final fakeFile = MockFile();
      final expectedPath = 'municipe123/photo.jpg';

      when(
        () => mockStorageFileApi.upload(expectedPath, any()),
      ).thenThrow(Exception('Bucket quota exceeded'));

      expect(
        () => storageService.uploadIssueImage(fakeFile, 'photo.jpg'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error uploading image:'),
          ),
        ),
      );
    });

    test('Should return correct public URL for a given path', () {
      final imagePath = 'municipe123/photo.jpg';
      final expectedUrl =
          'https://supabase.com/storage/v1/object/public/issue-images/municipe123/photo.jpg';

      when(
        () => mockStorageFileApi.getPublicUrl(imagePath),
      ).thenReturn(expectedUrl);

      final result = storageService.getPublicUrl(imagePath);

      expect(result, equals(expectedUrl));
      verify(() => mockStorageFileApi.getPublicUrl(imagePath)).called(1);
    });
  });
}
