import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

/// Mode tema yang dipilih pengguna.
enum AppThemeMode {
  system('Ikuti Sistem'),
  light('Terang'),
  dark('Gelap');

  const AppThemeMode(this.label);

  /// Label tampilan (Bahasa Indonesia).
  final String label;

  static AppThemeMode fromName(String? name) => AppThemeMode.values
      .firstWhere((m) => m.name == name, orElse: () => AppThemeMode.system);

  ThemeMode get materialMode => switch (this) {
        AppThemeMode.system => ThemeMode.system,
        AppThemeMode.light => ThemeMode.light,
        AppThemeMode.dark => ThemeMode.dark,
      };
}

/// Controller tema aplikasi (terang/gelap/ikuti sistem).
///
/// Menyimpan pilihan di SharedPreferences dan menyelaraskan
/// [AppColors.isDark] agar token warna statis mengikuti mode aktif.
class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs) {
    _mode = AppThemeMode.fromName(_prefs.getString(_kThemeMode));
    _syncTokens();
  }

  static const _kThemeMode = 'theme_mode';

  final SharedPreferences _prefs;
  late AppThemeMode _mode;

  AppThemeMode get mode => _mode;

  Future<void> setMode(AppThemeMode mode) async {
    if (mode == _mode) return;
    _mode = mode;
    await _prefs.setString(_kThemeMode, mode.name);
    _syncTokens();
    notifyListeners();
  }

  /// Selaraskan token warna statis dengan mode efektif saat ini.
  /// Dipanggil saat mode berubah dan saat brightness platform berubah
  /// (untuk mode "Ikuti Sistem").
  void refreshPlatformBrightness() {
    final before = AppColors.isDark;
    _syncTokens();
    if (AppColors.isDark != before) notifyListeners();
  }

  void _syncTokens() {
    AppColors.isDark = switch (_mode) {
      AppThemeMode.light => false,
      AppThemeMode.dark => true,
      AppThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark,
    };
  }
}
