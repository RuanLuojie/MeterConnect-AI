import 'package:flutter/material.dart';

class AppThemes {
  static final ThemeData darkTheme = ThemeData(
    primaryColor: Colors.black,
    colorScheme: ColorScheme.dark(
      primary: Colors.black,
      secondary: Colors.grey,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[800], // 替代 primary
        foregroundColor: Colors.white, // 替代 onPrimary
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // 圓角
        ),
      ),
    ),
  );
}
