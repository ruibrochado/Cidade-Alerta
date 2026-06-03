import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer';

class NotificationService {
  final FirebaseMessaging messaging;
  final Stream<RemoteMessage> onMessageStream;
  final Stream<RemoteMessage> onMessageOpenedAppStream;

  NotificationService({
    FirebaseMessaging? messagingInstance,
    Stream<RemoteMessage>? onMessage,
    Stream<RemoteMessage>? onMessageOpenedApp,
  }) : messaging = messagingInstance ?? FirebaseMessaging.instance,
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

    if (token != null) {
      await _saveFcmToken(token);
    }

    messaging.onTokenRefresh.listen((newToken) async {
      log('FCM token refreshed: $newToken');
      await _saveFcmToken(newToken);
    });

    onMessageStream.listen((RemoteMessage message) {
      log('Foreground message title: ${message.notification?.title}');
      log('Foreground message body: ${message.notification?.body}');
    });

    onMessageOpenedAppStream.listen((RemoteMessage message) {
      log('Notification opened app: ${message.messageId}');
    });
  }

  Future<void> _saveFcmToken(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      log('_saveFcmToken: no logged-in user, skipping.');
      return;
    }
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': token})
          .eq('id', user.id);
      log('FCM token saved for user ${user.id}');
    } catch (e) {
      log('Failed to save FCM token: $e');
    }
  }

  Future<void> clearFcmToken() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client
          .from('profiles')
          .update({'fcm_token': null})
          .eq('id', user.id);
      log('FCM token cleared for user ${user.id}');
    } catch (e) {
      log('Failed to clear FCM token: $e');
    }
  }
}
