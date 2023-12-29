import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uachado/screens/home_screen.dart';

import 'constants/app_theme.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? name = prefs.getString('name');
  if (kDebugMode) {
    print(name);
  }
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (isLoggedIn) {
      runApp(const MyApp(loggedIn: true));
    } else {
      runApp(const MyApp(loggedIn: false));
    }
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization failed: $e');
    }
    // Handle the error or show an error message to the user
  }
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UAchado',
      theme: appTheme, // Using the custom app theme
      home: loggedIn ? const HomeScreen() : LoginScreen(),
    );
  }
}
