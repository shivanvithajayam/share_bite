import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> init() async {
    await _fcm.requestPermission();
    final token = await _fcm.getToken();
    print('FCM Token: $token');
  }

  // Save FCM token to user's Firestore doc
  Future<void> saveFcmToken(String uid) async {
    final token = await _fcm.getToken();
    if (token != null) {
      await _db.collection('users').doc(uid).update({'fcmToken': token});
    }
  }

  // Called from Cloud Function — sends notification to all NGOs within 10 km
  // This is triggered automatically in Firestore when a new donation is created.
  // See: functions/index.js in your Firebase project

  // Handle foreground messages
  void listenForeground(Function(RemoteMessage) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  // Handle notification tap (app in background)
  void listenOnTap(Function(RemoteMessage) onTap) {
    FirebaseMessaging.onMessageOpenedApp.listen(onTap);
  }

  // Get initial message if app opened from terminated state
  Future<RemoteMessage?> getInitialMessage() {
    return _fcm.getInitialMessage();
  }
}
