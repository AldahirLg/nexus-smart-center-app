import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  debugPrint('FCM background: ${message.messageId}');

  debugPrint('Título: ${message.notification?.title}');

  debugPrint('Body: ${message.notification?.body}');

  debugPrint('Data: ${message.data}');
}

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Stream<String> get tokenRefresh => _messaging.onTokenRefresh;

  Future<String?> getFcmToken() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
    return await _messaging.getToken();
  }
}
