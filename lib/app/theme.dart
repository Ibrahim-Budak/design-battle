import 'package:flutter/material.dart';

abstract final class BattleColors {
  static const ink = Color(0xff1c2525);
  static const muted = Color(0xff6e7773);
  static const paper = Color(0xfff5f5ef);
  static const lime = Color(0xffd6ed83);
  static const line = Color(0xffe3e6de);
  static const orange = Color(0xffe77940);
}

ThemeData battleTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: BattleColors.ink,
    primary: BattleColors.ink,
    surface: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: BattleColors.paper,
    fontFamily: 'sans-serif',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.8,
        height: 1.05,
        color: BattleColors.ink,
      ),
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
        color: BattleColors.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -.4,
        color: BattleColors.ink,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: BattleColors.muted,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: BattleColors.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size(48, 50),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
      ),
    ),
  );
}
