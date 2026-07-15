import 'package:flutter/material.dart';
import 'app_colors.dart';

/// GiftsWale Typography System
/// Uses the Outfit font family, matching the website's design system.
///
/// 💡 React Native equivalent: StyleSheet.create({ ... })
/// In Flutter, we define TextStyles as constants and use them directly.
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Outfit';

  // ─── Display (Hero headings) ─────────────────────────────
  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32, // ~font-size-5xl (3.5rem scaled for mobile)
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -1.5,
    color: AppColors.text,
  );

  // ─── Heading Sizes ───────────────────────────────────────
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24, // font-size-4xl
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.text,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18, // font-size-3xl
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
    color: AppColors.text,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16, // font-size-2xl
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.text,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14, // font-size-xl
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.text,
  );

  // ─── Body ────────────────────────────────────────────────
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15, // font-size-lg
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14, // font-size-md (1rem)
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.text,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12, // font-size-sm
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.text,
  );

  static const TextStyle bodyXs = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10.5, // font-size-xs
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.text,
  );

  // ─── Labels ──────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    color: AppColors.primary,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  // ─── Price ───────────────────────────────────────────────
  static const TextStyle price = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle priceOriginal = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSubtle,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle priceDiscounted = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  // ─── Section Header Label ────────────────────────────────
  static const TextStyle sectionLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 2.0,
    color: AppColors.primary,
  );

  // ─── Input ───────────────────────────────────────────────
  static const TextStyle input = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSubtle,
  );
}
