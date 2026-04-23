import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

class NotificationService {
  final FirebaseMessaging messaging;
  final Stream<RemoteMessage> onMessageStream;
  final Stream<RemoteMessage> onMessageOpenedAppStream;

  NotificationService({
    FirebaseMessaging? messagingInstance,
    Stream<RemoteMessage>? onMessage,
    Stream<RemoteMessage>? onMessageOpenedApp,
  })  : messaging = messagingInstance ?? FirebaseMessaging.instance,
        onMessageStream = onMessage ?? FirebaseMessaging.onMessage,
        onMessageOpenedAppStream =
            onMessageOpenedApp ?? FirebaseMessaging.onMessageOpenedApp;

  Future<void> initialize() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('Notification permission: ${settings.authorizationStatus}');

    final token = await messaging.getToken();
    log('FCM token: $token');

    onMessageStream.listen((RemoteMessage message) {
      log('Foreground message title: ${message.notification?.title}');
      log('Foreground message body: ${message.notification?.body}');
    });

    onMessageOpenedAppStream.listen((RemoteMessage message) {
      log('Notification opened app: ${message.messageId}');
    });
  }
}