import 'package:flutter/material.dart';

import '../data/cities/city_repository.dart';
import '../features/hub/hub_feature_registry.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/qibla/qibla_controller.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/quran/quran_controller.dart';
import '../features/quran/quran_screen.dart';
import '../notifications/models/notification_settings.dart';
import 'app_shell.dart';
import 'injection.dart';
import 'splash_screen.dart';

/// Nama-nama rute aplikasi.
abstract final class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const today = '/';
  static const qibla = '/qibla';
  static const quran = '/quran';
  static const hub = '/hub';
  static const settings = '/settings';
}

/// Router pusat aplikasi.
///
/// Menyatukan navigasi seluruh modul. Fitur Hub yang masih stub
/// (belum tersedia) diarahkan ke halaman "Segera Hadir" alih-alih error.
abstract final class AppRouter {
  /// Rute awal berdasarkan status onboarding.
  static String initialRoute({required bool onboardingDone}) =>
      onboardingDone ? Routes.today : Routes.onboarding;

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final name = settings.name ?? Routes.today;

    // Fitur Hub yang belum tersedia -> placeholder "Segera Hadir".
    final hubFeature = HubFeatureRegistry.features
        .where((f) => f.route == name)
        .cast<HubFeature?>()
        .firstWhere((_) => true, orElse: () => null);
    if (hubFeature != null && !hubFeature.available) {
      return _page(
        _ComingSoonScreen(title: hubFeature.title),
        settings,
      );
    }

    return switch (name) {
      Routes.splash => _page(const SplashScreen(), settings),
      Routes.onboarding => MaterialPageRoute(
          settings: settings,
          builder: (context) => OnboardingScreen(
            controller: sl<OnboardingController>(),
            cityRepository: sl<CityRepository>(),
            notificationSettings: sl<NotificationSettingsRepository>(),
            onFinish: () => Navigator.of(context)
                .pushReplacementNamed(Routes.today),
          ),
        ),
      Routes.today => _page(const AppShell(), settings),
      Routes.hub => _page(const AppShell(initialIndex: 2), settings),
      Routes.settings => _page(const AppShell(initialIndex: 3), settings),
      // Deep-link langsung ke layar tunggal (mis. dari notifikasi/URL).
      Routes.qibla => _page(
          QiblaScreen(controller: sl<QiblaController>()),
          settings,
        ),
      Routes.quran => _page(
          QuranScreen(controller: sl<QuranController>()),
          settings,
        ),
      // Rute tak dikenal (mis. URL usang di web) — pulihkan lewat Splash
      // yang akan mengarahkan ke Beranda/Onboarding sesuai status.
      _ => _page(const SplashScreen(), settings),
    };
  }

  static MaterialPageRoute<dynamic> _page(Widget child, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => child, settings: s);
}

/// Placeholder "Segera Hadir" untuk fitur Hub yang belum tersedia.
class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('Segera Hadir')),
      );
}
