import 'package:firebase_messaging/firebase_messaging.dart';


class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission for notifications (iOS only)
    await _firebaseMessaging.requestPermission();

    // Configure FCM callbacks
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the incoming message when the app is in the foreground
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle the incoming message when the app is opened from a terminated state
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Handle the incoming message when the app is in the background
  }
}
