import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
      ),
    );
  }

  static Color get statusOpen => Colors.blue;
  static Color get statusInProgress => Colors.blueAccent;
  static Color get statusWaiting => Colors.orange;
  static Color get statusCompleted => Colors.green;
  static Color get statusCanceled => Colors.grey;

  static Color get priorityUrgent => Colors.red;
  static Color get priorityHigh => Colors.deepOrange;
  static Color get priorityMedium => Colors.orange;
  static Color get priorityLow => Colors.green;
}
