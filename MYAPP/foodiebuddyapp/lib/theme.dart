import 'package:flutter/material.dart';

class AppTheme {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.bold,
      fontSize: 32,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
      fontSize: 16,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
      fontSize: 14,
    ),
  );

  static final ThemeData themeData = ThemeData(
    textTheme: textTheme,
  );
}
