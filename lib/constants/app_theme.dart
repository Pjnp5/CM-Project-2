import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFcab6aa),
    secondary: const Color(0xFFe7d4ca),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
    filled: true,
    fillColor: Colors.white.withAlpha(230),
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFcab6aa),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
    ),
  ),
  useMaterial3: true,
);
