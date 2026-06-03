import 'dart:async';

import 'package:app/services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockNotificationSettings extends Mock implements NotificationSettings {}

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;
    late MockFirebaseMessaging mockMessaging;
    late StreamController<String> tokenRefreshController;
    late StreamController<RemoteMessage> onMessageController;
    late StreamController<RemoteMessage> onMessageOpenedAppController;

    setUp(() {
      mockMessaging = MockFirebaseMessaging();

      tokenRefreshController = StreamController<String>();
      onMessageController = StreamController<RemoteMessage>();
      onMessageOpenedAppController = StreamController<RemoteMessage>();

      when(
        () => mockMessaging.onTokenRefresh,
      ).thenAnswer((_) => tokenRefreshController.stream);

      notificationService = NotificationService(
        messagingInstance: mockMessaging,
        onMessage: onMessageController.stream,
        onMessageOpenedApp: onMessageOpenedAppController.stream,
      );
    });

    tearDown(() async {
      await tokenRefreshController.close();
      await onMessageController.close();
      await onMessageOpenedAppController.close();
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

      verify(
        () => mockMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        ),
      ).called(1);

      verify(() => mockMessaging.getToken()).called(1);
      verify(() => mockMessaging.onTokenRefresh).called(1);
    });
  });
}
