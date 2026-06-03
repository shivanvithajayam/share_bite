import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await messaging.requestPermission();

    const androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await localNotifications.initialize(
      const InitializationSettings(
        android: androidInit,
      ),
    );

    FirebaseMessaging.onMessage.listen((message) {
      localNotifications.show(
        0,
        message.notification?.title,
        message.notification?.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'sharebite_channel',
            'ShareBite Notifications',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    });
  }
}