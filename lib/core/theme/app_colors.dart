import 'package:flutter/material.dart';

/// GiftsWale Color System
/// Ported directly from the website's CSS custom properties in styles/index.css
class AppColors {
  AppColors._();

  // ─── Primary ─────────────────────────────────────────────
  static const Color primary = Color(0xFF516F2C);
  static const Color primaryDark = Color(0xFF3A5220);
  static const Color primaryLight = Color(0xFF709146);
  static const Color primaryGlow = Color(0x1F516F2C); // 12% opacity

  // ─── Backgrounds ─────────────────────────────────────────
  static const Color bg = Color(0xFFFFFFFF);
  static const Color bgSurface = Color(0xFFF6F5F2);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgElevated = Color(0xFFF0EEE9);
  static const Color bgInput = Color(0xFFFAFAFA);

  // ─── Text ────────────────────────────────────────────────
  static const Color text = Color(0xFF1B1B1B);
  static const Color textMuted = Color(0xFF5E5E6A);
  static const Color textSubtle = Color(0xFF8E8E9A);

  // ─── Borders ─────────────────────────────────────────────
  static const Color border = Color(0x14000000); // rgba(0,0,0,0.08)
  static const Color borderHover = Color(0x26000000); // rgba(0,0,0,0.15)

  // ─── Accents ─────────────────────────────────────────────
  static const Color gold = Color(0xFFFFD166);
  static const Color goldDark = Color(0xFFE6B84E);
  static const Color success = Color(0xFF06D6A0);
  static const Color warning = Color(0xFFFFD166);
  static const Color danger = Color(0xFFEF476F);
  static const Color info = Color(0xFF4CC9F0);

  // ─── Gradients ───────────────────────────────────────────
  static const LinearGradient gradientPrimary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient gradientHero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [bgSurface, bg],
  );

  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD166), Color(0xFFFF9F1C)],
  );

  // ─── Shadows ─────────────────────────────────────────────
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color(0x12000000),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 40,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0x33516F2C),
      blurRadius: 20,
      offset: Offset(0, 4),
    ),
  ];

  // ─── MaterialColor Swatch ────────────────────────────────
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF516F2C,
    <int, Color>{
      50: Color(0xFFF0F4EC),
      100: Color(0xFFD9E3CE),
      200: Color(0xFFC0D0AE),
      300: Color(0xFFA7BD8E),
      400: Color(0xFF94AF76),
      500: Color(0xFF81A15E),
      600: Color(0xFF709146),
      700: Color(0xFF5E8038),
      800: Color(0xFF516F2C),
      900: Color(0xFF3A5220),
    },
  );
}
