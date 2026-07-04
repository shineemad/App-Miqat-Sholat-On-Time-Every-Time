import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Skala tipografi Neo-Brutalist (§8.3).
///
/// Headings memakai **Poppins**, body memakai **Inter**.
abstract final class AppTypography {
  static const String headingFamily = 'Poppins';
  static const String bodyFamily = 'Inter';

  /// TextTheme lengkap untuk ThemeData.
  static const TextTheme textTheme = TextTheme(
    // Display — font-bold tracking-tight (dipakai countdown hero).
    displayLarge: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 57,
      letterSpacing: -1.0,
      height: 1.05,
      color: AppColors.onSurface,
    ),
    displayMedium: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 45,
      letterSpacing: -0.5,
      height: 1.05,
      color: AppColors.onSurface,
    ),
    displaySmall: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 36,
      letterSpacing: -0.5,
      color: AppColors.onSurface,
    ),
    // Headline — font-bold.
    headlineLarge: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      color: AppColors.onSurface,
    ),
    headlineMedium: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: AppColors.onSurface,
    ),
    headlineSmall: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      color: AppColors.onSurface,
    ),
    // Title — font-semibold.
    titleLarge: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      color: AppColors.onSurface,
    ),
    titleMedium: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.15,
      color: AppColors.onSurface,
    ),
    titleSmall: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0.1,
      color: AppColors.onSurface,
    ),
    // Body — Inter font-normal.
    bodyLarge: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.4,
      color: AppColors.onSurface,
    ),
    bodyMedium: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.4,
      color: AppColors.onSurface,
    ),
    bodySmall: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 1.35,
      color: AppColors.onSurfaceVariant,
    ),
    // Label — Inter medium (dipakai tombol & chip).
    labelLarge: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0.1,
      color: AppColors.onSurface,
    ),
    labelMedium: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      letterSpacing: 0.5,
      color: AppColors.onSurface,
    ),
    labelSmall: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      letterSpacing: 0.5,
      color: AppColors.onSurfaceVariant,
    ),
  );
}
