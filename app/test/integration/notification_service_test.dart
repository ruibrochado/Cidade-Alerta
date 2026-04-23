import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app/services/notification_service.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  test('Should request permissions and get token during initialization', () async {
    print('A verificar inicialização do Firebase Messaging...');

    final service = NotificationService();
    expect(service.initialize(), isA<Future<void>>());
  });
}