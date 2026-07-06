import 'package:flutter/material.dart';

/// Palet terang — Design System "Neo-Brutalist Prayer Companion" v1.1.0 (§8.2).
abstract final class AppColorsLight {
  // --- Base Surface ---
  static const surface = Color(0xFFFCF9F8); // Cream/Beige base
  static const surfaceDim = Color(0xFFDCD9D9);
  static const surfaceBright = Color(0xFFFCF9F8);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF6F3F2);
  static const surfaceContainer = Color(0xFFF1EDEB);
  static const surfaceContainerHigh = Color(0xFFEBE7E5);
  static const surfaceContainerHighest = Color(0xFFE5E1DF);

  // --- Primary (Coral) ---
  static const primary = Color(0xFFFF5A3C);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFFFDAD4);
  static const onPrimaryContainer = Color(0xFF3B0904);

  // --- Secondary (Teal) ---
  static const secondary = Color(0xFF2FD9A8);
  static const onSecondary = Color(0xFF003828);
  static const secondaryContainer = Color(0xFFB3F7DF);
  static const onSecondaryContainer = Color(0xFF002116);

  // --- Tertiary (Yellow) ---
  static const tertiary = Color(0xFFFFC34D);
  static const onTertiary = Color(0xFF251A00);
  static const tertiaryContainer = Color(0xFFFFE0A1);
  static const onTertiaryContainer = Color(0xFF251A00);

  // --- Borders & Text ---
  static const outline = Color(0xFF1C1B1B);
  static const outlineVariant = Color(0xFF49454F);
  static const onSurface = Color(0xFF1C1B1B);
  static const onSurfaceVariant = Color(0xFF49454F);

  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
}

/// Palet gelap — turunan Neo-Brutalist untuk pemakaian malam (Subuh/Isya).
///
/// Border & hard shadow dibalik menjadi terang agar bahasa desain
/// "garis tegas" tetap terbaca di atas permukaan gelap.
abstract final class AppColorsDark {
  // --- Base Surface (warm dark) ---
  static const surface = Color(0xFF171514);
  static const surfaceDim = Color(0xFF121010);
  static const surfaceBright = Color(0xFF3A3735);
  static const surfaceContainerLowest = Color(0xFF0F0D0C);
  static const surfaceContainerLow = Color(0xFF1D1B1A);
  static const surfaceContainer = Color(0xFF232120);
  static const surfaceContainerHigh = Color(0xFF2B2927);
  static const surfaceContainerHighest = Color(0xFF343130);

  // --- Primary (Coral) ---
  static const primary = Color(0xFFFF6B4F);
  static const onPrimary = Color(0xFF3B0904);
  static const primaryContainer = Color(0xFF5C1A0E);
  static const onPrimaryContainer = Color(0xFFFFDAD4);

  // --- Secondary (Teal) ---
  static const secondary = Color(0xFF2FD9A8);
  static const onSecondary = Color(0xFF003828);
  static const secondaryContainer = Color(0xFF00513C);
  static const onSecondaryContainer = Color(0xFFB3F7DF);

  // --- Tertiary (Yellow) ---
  static const tertiary = Color(0xFFFFC34D);
  static const onTertiary = Color(0xFF251A00);
  static const tertiaryContainer = Color(0xFF5C4200);
  static const onTertiaryContainer = Color(0xFFFFE0A1);

  // --- Borders & Text ---
  static const outline = Color(0xFFE8E4E1);
  static const outlineVariant = Color(0xFFCAC5C0);
  static const onSurface = Color(0xFFF2EEEC);
  static const onSurfaceVariant = Color(0xFFCAC5C0);

  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
}

/// Token warna aktif aplikasi.
///
/// Nilai mengikuti [isDark] yang diselaraskan oleh `ThemeController`
/// sebelum rebuild tree, sehingga seluruh widget yang membaca token ini
/// otomatis mengikuti mode terang/gelap. Jangan hardcode hex di widget —
/// selalu pakai token ini agar konsisten & mudah dievolusi.
abstract final class AppColors {
  /// Diselaraskan oleh ThemeController; jangan diubah langsung dari widget.
  static bool isDark = false;

  // --- Base Surface ---
  static Color get surface =>
      isDark ? AppColorsDark.surface : AppColorsLight.surface;
  static Color get surfaceDim =>
      isDark ? AppColorsDark.surfaceDim : AppColorsLight.surfaceDim;
  static Color get surfaceBright =>
      isDark ? AppColorsDark.surfaceBright : AppColorsLight.surfaceBright;
  static Color get surfaceContainerLowest => isDark
      ? AppColorsDark.surfaceContainerLowest
      : AppColorsLight.surfaceContainerLowest;
  static Color get surfaceContainerLow => isDark
      ? AppColorsDark.surfaceContainerLow
      : AppColorsLight.surfaceContainerLow;
  static Color get surfaceContainer => isDark
      ? AppColorsDark.surfaceContainer
      : AppColorsLight.surfaceContainer;
  static Color get surfaceContainerHigh => isDark
      ? AppColorsDark.surfaceContainerHigh
      : AppColorsLight.surfaceContainerHigh;
  static Color get surfaceContainerHighest => isDark
      ? AppColorsDark.surfaceContainerHighest
      : AppColorsLight.surfaceContainerHighest;

  // --- Primary (Coral) ---
  static Color get primary =>
      isDark ? AppColorsDark.primary : AppColorsLight.primary;
  static Color get onPrimary =>
      isDark ? AppColorsDark.onPrimary : AppColorsLight.onPrimary;
  static Color get primaryContainer => isDark
      ? AppColorsDark.primaryContainer
      : AppColorsLight.primaryContainer;
  static Color get onPrimaryContainer => isDark
      ? AppColorsDark.onPrimaryContainer
      : AppColorsLight.onPrimaryContainer;

  // --- Secondary (Teal) ---
  static Color get secondary =>
      isDark ? AppColorsDark.secondary : AppColorsLight.secondary;
  static Color get onSecondary =>
      isDark ? AppColorsDark.onSecondary : AppColorsLight.onSecondary;
  static Color get secondaryContainer => isDark
      ? AppColorsDark.secondaryContainer
      : AppColorsLight.secondaryContainer;
  static Color get onSecondaryContainer => isDark
      ? AppColorsDark.onSecondaryContainer
      : AppColorsLight.onSecondaryContainer;

  // --- Tertiary (Yellow) ---
  static Color get tertiary =>
      isDark ? AppColorsDark.tertiary : AppColorsLight.tertiary;
  static Color get onTertiary =>
      isDark ? AppColorsDark.onTertiary : AppColorsLight.onTertiary;
  static Color get tertiaryContainer => isDark
      ? AppColorsDark.tertiaryContainer
      : AppColorsLight.tertiaryContainer;
  static Color get onTertiaryContainer => isDark
      ? AppColorsDark.onTertiaryContainer
      : AppColorsLight.onTertiaryContainer;

  // --- Borders & Text ---
  static Color get outline =>
      isDark ? AppColorsDark.outline : AppColorsLight.outline;
  static Color get outlineVariant =>
      isDark ? AppColorsDark.outlineVariant : AppColorsLight.outlineVariant;
  static Color get onSurface =>
      isDark ? AppColorsDark.onSurface : AppColorsLight.onSurface;
  static Color get onSurfaceVariant => isDark
      ? AppColorsDark.onSurfaceVariant
      : AppColorsLight.onSurfaceVariant;
}

/// Konstanta bentuk & elevasi Neo-Brutalist (§8.4).
abstract final class AppShapes {
  /// Ketebalan border standar (3px).
  static const double borderWidth = 3.0;

  /// Radius kartu (20px).
  static const double cardRadius = 20.0;

  static const BorderRadius card =
      BorderRadius.all(Radius.circular(cardRadius));

  /// Border tegas standar (hitam di mode terang, terang di mode gelap).
  static Border get hardBorder => Border.fromBorderSide(
        BorderSide(color: AppColors.outline, width: borderWidth),
      );

  /// Hard shadow 4px 4px 0 (offset diskrit, tanpa blur).
  static List<BoxShadow> get hardShadow => [
        BoxShadow(
          color: AppColors.outline,
          offset: const Offset(4, 4),
          blurRadius: 0,
          spreadRadius: 0,
        ),
      ];

  static const List<BoxShadow> noShadow = [];
}

/// Token spasi (§8.6).
abstract final class AppSpacing {
  static const double container = 16.0;
  static const double stack = 12.0;
  static const double inline = 8.0;

  /// Target sentuh minimum aksesibilitas (§8.8).
  static const double minTouchTarget = 44.0;
}
