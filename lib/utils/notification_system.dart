import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GlobalKey<ScaffoldMessengerState> scaffoldKey;
  final RegExp pattern = RegExp(r'[^a-zA-Z0-9-_]');

  FCMService({required this.scaffoldKey});

  Future<void> initialize() async {
    // Request permission for notifications (iOS only)
    await _firebaseMessaging.requestPermission();

    // Configure FCM callbacks
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle the incoming message when the app is in the foreground
      final notification = message.notification;
      final data = message.data;

      // Show a snackbar with the notification content
      showSnackbar(
        'New Notification',
        '${notification?.title ?? ''}: ${notification?.body ?? ''}',
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle the incoming message when the app is opened from a terminated state
      final data = message.data;

      // Example: Navigate the user to a specific screen based on notification data
      if (data['screen'] == 'your_screen_name') {
        // Navigate to the specified screen
        // Navigator.pushNamed(context, '/your_screen_route');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    if (kDebugMode) {
      print("FCM Token: $token");
    }
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Handle the incoming message when the app is in the background
  }

  Future<void> subscribeToTopic(List<String> topics) async {
    for (String topicName in topics) {
      // Replace any matching characters with an empty string
      topicName = topicName.replaceAll(pattern, '');
      await _firebaseMessaging.subscribeToTopic(topicName);
      if (kDebugMode) {
        print("Subscribed to $topicName");
      }
    }
  }

  Future<void> unsubscribeFromTopics(List<String> topics) async {
    for (String topicName in topics) {
      topicName = topicName.replaceAll(pattern, '');
      await _firebaseMessaging.unsubscribeFromTopic(topicName);
      if (kDebugMode) {
        print("Unsubscribed from $topicName");
      }
    }
  }

  void showSnackbar(String title, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    scaffoldKey.currentState?.showSnackBar(snackBar);
  }
}
