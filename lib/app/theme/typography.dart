import 'package:flutter/material.dart';

 
class AppTypography {
  static const String fontFamily = 'Roboto';

  static TextTheme buildTextTheme(Color color) => TextTheme(
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 60,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.0,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 48,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.1,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 36,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.2,
        ),
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 30,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.3,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: color,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: color.withOpacity(0.9),
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.4,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.4,
          letterSpacing: 0.1,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
          height: 1.3,
          letterSpacing: 0.2,
        ),
      );
}


