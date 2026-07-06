import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// ThemeData aplikasi berbasis Design System Neo-Brutalist (§8).
///
/// Tersedia tema terang (cream base, kontras tinggi untuk outdoor) dan
/// tema gelap (warm dark untuk pemakaian Subuh/Isya).
abstract final class AppTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: const ColorScheme(
          brightness: Brightness.light,
          primary: AppColorsLight.primary,
          onPrimary: AppColorsLight.onPrimary,
          primaryContainer: AppColorsLight.primaryContainer,
          onPrimaryContainer: AppColorsLight.onPrimaryContainer,
          secondary: AppColorsLight.secondary,
          onSecondary: AppColorsLight.onSecondary,
          secondaryContainer: AppColorsLight.secondaryContainer,
          onSecondaryContainer: AppColorsLight.onSecondaryContainer,
          tertiary: AppColorsLight.tertiary,
          onTertiary: AppColorsLight.onTertiary,
          tertiaryContainer: AppColorsLight.tertiaryContainer,
          onTertiaryContainer: AppColorsLight.onTertiaryContainer,
          error: AppColorsLight.error,
          onError: AppColorsLight.onError,
          surface: AppColorsLight.surface,
          onSurface: AppColorsLight.onSurface,
          surfaceContainerLowest: AppColorsLight.surfaceContainerLowest,
          surfaceContainerLow: AppColorsLight.surfaceContainerLow,
          surfaceContainer: AppColorsLight.surfaceContainer,
          surfaceContainerHigh: AppColorsLight.surfaceContainerHigh,
          surfaceContainerHighest: AppColorsLight.surfaceContainerHighest,
          surfaceDim: AppColorsLight.surfaceDim,
          surfaceBright: AppColorsLight.surfaceBright,
          onSurfaceVariant: AppColorsLight.onSurfaceVariant,
          outline: AppColorsLight.outline,
          outlineVariant: AppColorsLight.outlineVariant,
        ),
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: AppColorsDark.primary,
          onPrimary: AppColorsDark.onPrimary,
          primaryContainer: AppColorsDark.primaryContainer,
          onPrimaryContainer: AppColorsDark.onPrimaryContainer,
          secondary: AppColorsDark.secondary,
          onSecondary: AppColorsDark.onSecondary,
          secondaryContainer: AppColorsDark.secondaryContainer,
          onSecondaryContainer: AppColorsDark.onSecondaryContainer,
          tertiary: AppColorsDark.tertiary,
          onTertiary: AppColorsDark.onTertiary,
          tertiaryContainer: AppColorsDark.tertiaryContainer,
          onTertiaryContainer: AppColorsDark.onTertiaryContainer,
          error: AppColorsDark.error,
          onError: AppColorsDark.onError,
          surface: AppColorsDark.surface,
          onSurface: AppColorsDark.onSurface,
          surfaceContainerLowest: AppColorsDark.surfaceContainerLowest,
          surfaceContainerLow: AppColorsDark.surfaceContainerLow,
          surfaceContainer: AppColorsDark.surfaceContainer,
          surfaceContainerHigh: AppColorsDark.surfaceContainerHigh,
          surfaceContainerHighest: AppColorsDark.surfaceContainerHighest,
          surfaceDim: AppColorsDark.surfaceDim,
          surfaceBright: AppColorsDark.surfaceBright,
          onSurfaceVariant: AppColorsDark.onSurfaceVariant,
          outline: AppColorsDark.outline,
          outlineVariant: AppColorsDark.outlineVariant,
        ),
      );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      fontFamily: AppTypography.bodyFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppTypography.headingFamily,
          fontWeight: FontWeight.w700,
          fontSize: 22,
          color: scheme.onSurface,
        ),
        shape: Border(
          bottom: BorderSide(
            color: scheme.outline,
            width: AppShapes.borderWidth,
          ),
        ),
      ),
      splashColor: scheme.primary.withValues(alpha: 0.12),
      highlightColor: scheme.primary.withValues(alpha: 0.08),
    );
  }
}
