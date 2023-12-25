import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'constants/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UAchado',
      theme: appTheme, // Using the custom app theme
      home: const LoginScreen(),
    );
  }
}
