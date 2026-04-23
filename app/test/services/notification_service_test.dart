import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:app/services/notification_service.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;
    late MockFirebaseMessaging mockMessaging;
    late StreamController<RemoteMessage> onMessageController;
    late StreamController<RemoteMessage> onMessageOpenedAppController;

    setUp(() {
      mockMessaging = MockFirebaseMessaging();
      onMessageController = StreamController<RemoteMessage>();
      onMessageOpenedAppController = StreamController<RemoteMessage>();

      notificationService = NotificationService(
        messagingInstance: mockMessaging,
        onMessage: onMessageController.stream,
        onMessageOpenedApp: onMessageOpenedAppController.stream,
      );
    });

    tearDown(() {
      onMessageController.close();
      onMessageOpenedAppController.close();
    });

    test('Should initialize, request permissions and fetch token', () async {
      final mockSettings = MockNotificationSettings();

      when(
        () => mockSettings.authorizationStatus,
      ).thenReturn(AuthorizationStatus.authorized);

      when(
        () => mockMessaging.requestPermission(
          alert: any(named: 'alert'),
          announcement: any(named: 'announcement'),
          badge: any(named: 'badge'),
          carPlay: any(named: 'carPlay'),
          criticalAlert: any(named: 'criticalAlert'),
          provisional: any(named: 'provisional'),
          sound: any(named: 'sound'),
        ),
      ).thenAnswer((_) async => mockSettings);

      when(
        () => mockMessaging.getToken(),
      ).thenAnswer((_) async => 'fake_fcm_token_999');

      await notificationService.initialize();

      verify(() => mockMessaging.getToken()).called(1);
    });
  });
}
