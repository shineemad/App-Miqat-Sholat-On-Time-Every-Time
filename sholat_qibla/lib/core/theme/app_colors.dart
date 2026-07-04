import 'package:flutter/material.dart';

/// Token warna Design System "Neo-Brutalist Prayer Companion" v1.1.0.
///
/// Nilai diambil langsung dari spesifikasi design system (lihat
/// `struktur-uiux-app-sholat-qibla.md` §8.2). Jangan hardcode hex di widget —
/// selalu pakai token ini agar konsisten & mudah dievolusi.
abstract final class AppColors {
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

  // --- Borders & Shadows ---
  /// Hitam tegas untuk border & hard shadow.
  static const outline = Color(0xFF1C1B1B);
  static const outlineVariant = Color(0xFF49454F);

  /// Warna teks utama di atas permukaan terang.
  static const onSurface = Color(0xFF1C1B1B);
  static const onSurfaceVariant = Color(0xFF49454F);
}

/// Konstanta bentuk & elevasi Neo-Brutalist (§8.4).
abstract final class AppShapes {
  /// Ketebalan border standar (3px).
  static const double borderWidth = 3.0;

  /// Radius kartu (20px).
  static const double cardRadius = 20.0;

  static const BorderRadius card =
      BorderRadius.all(Radius.circular(cardRadius));

  /// Border hitam tegas standar.
  static const Border hardBorder = Border.fromBorderSide(
    BorderSide(color: AppColors.outline, width: borderWidth),
  );

  /// Hard shadow 4px 4px 0 (offset diskrit, tanpa blur).
  static const List<BoxShadow> hardShadow = [
    BoxShadow(
      color: AppColors.outline,
      offset: Offset(4, 4),
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
