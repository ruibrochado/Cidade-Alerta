import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer';

class NotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    log('Notification permission: ${settings.authorizationStatus}');

    final token = await messaging.getToken();
    log('FCM token: $token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log('Foreground message title: ${message.notification?.title}');
      log('Foreground message body: ${message.notification?.body}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log('Notification opened app: ${message.messageId}');
    });
  }
}