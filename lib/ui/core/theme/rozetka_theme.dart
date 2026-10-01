import 'package:flutter/material.dart';

/// Rozetka-inspired colors: green primary, white surfaces, light page background.
abstract final class RozetkaColors {
  static const green = Color(0xFF22B24C);
  static const greenDark = Color(0xFF189143);
  static const ink = Color(0xFF1A1A1A);
  static const muted = Color(0xFF6B7280);
  static const page = Color(0xFFF4F5F7);
  static const line = Color(0xFFE6E8EC);
  static const errorBackground = Color(0xFFFFF1F0);
  static const error = Color(0xFFD92D20);
}

ThemeData buildRozetkaTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: RozetkaColors.green,
    primary: RozetkaColors.green,
    onPrimary: Colors.white,
    surface: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: RozetkaColors.page,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: RozetkaColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.white,
      shape: Border(bottom: BorderSide(color: RozetkaColors.line)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RozetkaColors.green,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFB7E4C4),
        minimumSize: const Size(64, 48),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RozetkaColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RozetkaColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: RozetkaColors.green, width: 2),
      ),
    ),
  );
}
