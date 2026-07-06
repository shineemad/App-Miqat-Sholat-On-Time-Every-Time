import 'package:flutter/material.dart';


/// Warna teks tidak di-hardcode di sini — diterapkan oleh AppTheme sesuai
/// ColorScheme aktif (terang/gelap).
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
    ),
    displayMedium: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 45,
      letterSpacing: -0.5,
      height: 1.05,
    ),
    displaySmall: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 36,
      letterSpacing: -0.5,
    ),
    // Headline — font-bold.
    headlineLarge: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 32,
    ),
    headlineMedium: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 28,
    ),
    headlineSmall: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w700,
      fontSize: 24,
    ),
    // Title — font-semibold.
    titleLarge: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w600,
      fontSize: 22,
    ),
    titleMedium: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: headingFamily,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0.1,
    ),
    // Body — Inter font-normal.
    bodyLarge: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 1.4,
    ),
    bodyMedium: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w400,
      fontSize: 14,
      height: 1.4,
    ),
    bodySmall: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 1.35,
    ),
    // Label — Inter medium (dipakai tombol & chip).
    labelLarge: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w600,
      fontSize: 14,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w500,
      fontSize: 12,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: bodyFamily,
      fontWeight: FontWeight.w500,
      fontSize: 11,
      letterSpacing: 0.5,
    ),
  );
}
