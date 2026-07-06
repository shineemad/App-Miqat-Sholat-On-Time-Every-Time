import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../l10n/app_localizations.dart';
import 'app_router.dart';
import 'injection.dart';

/// Widget root aplikasi Miqat.
class MiqatApp extends StatefulWidget {
  const MiqatApp({super.key});

  @override
  State<MiqatApp> createState() => _MiqatAppState();
}

class _MiqatAppState extends State<MiqatApp> with WidgetsBindingObserver {
  late final ThemeController _theme = sl<ThemeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    // Mode "Ikuti Sistem": selaraskan token warna saat OS berganti tema.
    _theme.refreshPlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _theme,
      builder: (context, _) => MaterialApp(
        title: 'Miqat',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _theme.mode.materialMode,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // Default Bahasa Indonesia; ikuti perangkat bila didukung (EN/AR).
        locale: const Locale('id'),
        // Selalu mulai dari Splash, apa pun URL awal browser (web). Ini
        // mencegah konflik antara initialRoute dan path URL yang bisa
        // memunculkan halaman "tidak ditemukan".
        onGenerateInitialRoutes: (_) => [
          AppRouter.onGenerateRoute(
            const RouteSettings(name: Routes.splash),
          ),
        ],
        initialRoute: Routes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
