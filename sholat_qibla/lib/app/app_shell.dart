import 'package:flutter/material.dart';

import '../core/theme/theme_controller.dart';
import '../core/widgets/neo_bottom_nav.dart';
import '../data/cities/city_repository.dart';
import '../features/hub/hub_feature_registry.dart';
import '../features/hub/hub_screen.dart';
import '../features/hub/hijri_screen.dart';
import '../features/hub/tasbih_counter.dart';
import '../features/hub/tasbih_screen.dart';
import '../features/qibla/qibla_controller.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/quran/quran_controller.dart';
import '../features/quran/quran_screen.dart';
import '../features/settings/settings_controller.dart';
import '../features/settings/settings_screen.dart';
import '../features/today/today_controller.dart';
import '../features/today/today_screen.dart';
import 'injection.dart';

/// Shell aplikasi dengan tab bar 4 slot tetap (§2 Information Architecture):
/// Beranda · Kiblat · Hub · Pengaturan.
///
/// Al-Quran tidak lagi menjadi tab tersendiri — diakses sebagai fitur di
/// dalam Hub. State tiap tab dipertahankan lewat [IndexedStack].
class AppShell extends StatefulWidget {
  const AppShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _index = widget.initialIndex;

  static const _items = [
    NeoNavItem(icon: Icons.home_rounded, label: 'Beranda'),
    NeoNavItem(icon: Icons.explore_rounded, label: 'Kiblat'),
    NeoNavItem(icon: Icons.widgets_rounded, label: 'Hub'),
    NeoNavItem(icon: Icons.settings_rounded, label: 'Atur'),
  ];

  void _goTo(int index) => setState(() => _index = index);

  void _openHubFeature(HubFeature feature) {
    switch (feature.id) {
      case 'tasbih':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TasbihScreen(counter: sl<TasbihCounter>()),
        ));
      case 'hijri':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => const HijriScreen(),
        ));
      case 'quran':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => QuranScreen(controller: sl<QuranController>()),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      TodayScreen(
        controller: sl<TodayController>(),
        onOpenQibla: () => _goTo(1),
      ),
      QiblaScreen(controller: sl<QiblaController>()),
      HubScreen(onOpenFeature: _openHubFeature),
      SettingsScreen(
        controller: sl<SettingsController>(),
        cityRepository: sl<CityRepository>(),
        themeController: sl<ThemeController>(),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: NeoBottomNav(
        items: _items,
        currentIndex: _index,
        onTap: _goTo,
      ),
    );
  }
}
