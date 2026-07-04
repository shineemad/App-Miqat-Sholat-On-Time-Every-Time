import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'app_router.dart';

/// Widget root aplikasi Miqat.
class MiqatApp extends StatelessWidget {
  const MiqatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miqat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
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
    );
  }
}
