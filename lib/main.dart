import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/donor/donor_home_screen.dart';
import 'screens/ngo/ngo_home_screen.dart';

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const ShareBiteApp());
}

class ShareBiteApp extends StatelessWidget {
  const ShareBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareBite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashRouter(),
    );
  }
}

// Auto-route to correct screen based on auth state
class SplashRouter extends StatefulWidget {
  const SplashRouter({super.key});

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}

class _SplashRouterState extends State<SplashRouter> {
  final _auth = AuthService();
  final _notif = NotificationService();

  @override
  void initState() {
    super.initState();
    _notif.init();
    _setupNotificationHandlers();
  }

  void _setupNotificationHandlers() {
    // Foreground notification
    _notif.listenForeground((message) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.notification?.title ?? 'New donation nearby!'),
          action: SnackBarAction(label: 'View', onPressed: () {}),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _auth.authStateChanges,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.cream,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🍱', style: TextStyle(fontSize: 56)),
                  SizedBox(height: 16),
                  Text(
                    'ShareBite',
                    style: TextStyle(
                      fontFamily: 'DM Serif Display',
                      fontSize: 28,
                      color: AppColors.teal,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(color: AppColors.teal),
                ],
              ),
            ),
          );
        }
        if (snap.data == null) return const LoginScreen();
        return FutureBuilder(
          future: _auth.getCurrentUserModel(),
          builder: (ctx, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.cream,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.teal),
                ),
              );
            }
            final user = userSnap.data;
            if (user == null) return const LoginScreen();
            // Save FCM token on login
            _notif.saveFcmToken(user.uid);
            if (user.role == 'donor') {
              return DonorHomeScreen(user: user);
            } else {
              return NgoHomeScreen(user: user);
            }
          },
        );
      },
    );
  }
}
