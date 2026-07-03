import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_widget.dart';
import '../../app/providers.dart';
import '../../data/cities/city_model.dart';
import '../../data/location/location_mode.dart';

/// Onboarding multi-step — tampil hanya sekali saat pertama buka.
///
/// 4 halaman:
///   1. Welcome — nilai aplikasi
///   2. Izin Lokasi — GPS atau kota manual
///   3. Metode Perhitungan — Kemenag + madzhab Ashar
///   4. Notifikasi — aktifkan atau lewati
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < 3) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = ref.read(appPreferencesProvider).valueOrNull;
    await prefs?.setOnboardingCompleted();
    ref.invalidate(appPreferencesProvider);
    // Navigasi ke shell utama
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress indicator ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: List.generate(4, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: i <= _page
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // ── Pages ────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(onNext: _next),
                  _LocationPage(onNext: _next),
                  _MethodPage(onNext: _next),
                  _NotificationPage(onFinish: _finish),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Halaman 1: Welcome ────────────────────────────────────────────────────

class _WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  const _WelcomePage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mosque, size: 96, color: colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            'Sholat Tepat Waktu,\nPrivasi Terjaga',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Waktu sholat dan arah kiblat dihitung langsung di perangkat Anda — '
            'tanpa internet, tanpa akun, tanpa iklan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          _FeatureRow(Icons.offline_bolt, 'Offline sepenuhnya'),
          const SizedBox(height: 12),
          _FeatureRow(Icons.lock_outline, 'Lokasi tidak keluar dari perangkat'),
          const SizedBox(height: 12),
          _FeatureRow(Icons.notifications_none, 'Pengingat per-sholat yang bisa diatur'),
          const SizedBox(height: 48),
          FilledButton(
            onPressed: onNext,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child: const Text('Mulai'),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

// ── Halaman 2: Izin Lokasi ────────────────────────────────────────────────

class _LocationPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const _LocationPage({required this.onNext});

  @override
  ConsumerState<_LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<_LocationPage> {
  bool _showCityPicker = false;

  Future<void> _useGps() async {
    final prefs = ref.read(appPreferencesProvider).valueOrNull;
    if (prefs == null) { widget.onNext(); return; }

    final locationProv = ref.read(locationProviderProvider);
    await locationProv.requestPermission();
    await prefs.setLocationMode(LocationMode.gps);
    ref.invalidate(locationProviderProvider);
    ref.invalidate(locationInfoProvider);
    widget.onNext();
  }

  Future<void> _selectCity(CityModel city) async {
    final prefs = ref.read(appPreferencesProvider).valueOrNull;
    if (prefs == null) { widget.onNext(); return; }
    await prefs.setLocationMode(LocationMode.manual);
    await prefs.setSelectedCityId(city.id);
    ref.invalidate(locationProviderProvider);
    ref.invalidate(locationInfoProvider);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    if (_showCityPicker) {
      return _CityPicker(onSelected: _selectCity);
    }

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_outlined, size: 72, color: colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Izin Lokasi',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Aplikasi membutuhkan lokasi Anda untuk menghitung waktu sholat '
            'yang akurat. Lokasi tidak pernah dikirim ke server mana pun.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: _useGps,
            icon: const Icon(Icons.gps_fixed),
            label: const Text('Gunakan Lokasi (Saat Digunakan)'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => setState(() => _showCityPicker = true),
            icon: const Icon(Icons.location_city),
            label: const Text('Pilih Kota Manual'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
        ],
      ),
    );
  }
}

/// Picker kota untuk onboarding dan settings.
class _CityPicker extends ConsumerWidget {
  final void Function(CityModel) onSelected;
  const _CityPicker({required this.onSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cities = ref.watch(filteredCitiesProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Cari kota...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (q) =>
                ref.read(citySearchQueryProvider.notifier).state = q,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: cities.length,
            itemBuilder: (_, i) {
              final city = cities[i];
              return ListTile(
                leading: const Icon(Icons.location_city_outlined),
                title: Text(city.name),
                subtitle: Text(city.province),
                onTap: () => onSelected(city),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Halaman 3: Metode Perhitungan ─────────────────────────────────────────

class _MethodPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const _MethodPage({required this.onNext});

  @override
  ConsumerState<_MethodPage> createState() => _MethodPageState();
}

class _MethodPageState extends ConsumerState<_MethodPage> {
  String _method = 'Kemenag';
  String _madhab = 'Shafii';

  Future<void> _save() async {
    final prefs = ref.read(appPreferencesProvider).valueOrNull;
    if (prefs != null) {
      await prefs.setCalculationMethod(_method);
      await prefs.setAshrMadhab(_madhab);
      ref.invalidate(prayerTimesProvider);
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Icon(Icons.calculate_outlined, size: 56,
              color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Metode Perhitungan',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Pilih metode yang sesuai dengan wilayah Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 24),
          // Metode
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Metode Perhitungan',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                RadioListTile(
                  title: const Text('Kemenag (Dianjurkan)'),
                  subtitle: const Text('Fajr 20°, Isha 18° — Indonesia'),
                  value: 'Kemenag',
                  groupValue: _method,
                  onChanged: (v) => setState(() => _method = v!),
                ),
                RadioListTile(
                  title: const Text('MWL'),
                  subtitle: const Text('Muslim World League'),
                  value: 'MWL',
                  groupValue: _method,
                  onChanged: (v) => setState(() => _method = v!),
                ),
                RadioListTile(
                  title: const Text('ISNA'),
                  subtitle: const Text('Islamic Society of North America'),
                  value: 'ISNA',
                  groupValue: _method,
                  onChanged: (v) => setState(() => _method = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Madzhab Ashar
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Waktu Ashar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1),
                RadioListTile(
                  title: const Text("Syafi'i"),
                  subtitle: const Text("Bayangan objek = 1× tingginya"),
                  value: 'Shafii',
                  groupValue: _madhab,
                  onChanged: (v) => setState(() => _madhab = v!),
                ),
                RadioListTile(
                  title: const Text('Hanafi'),
                  subtitle: const Text('Bayangan objek = 2× tingginya'),
                  value: 'Hanafi',
                  groupValue: _madhab,
                  onChanged: (v) => setState(() => _madhab = v!),
                ),
              ],
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _save,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child: const Text('Lanjut'),
          ),
        ],
      ),
    );
  }
}

// ── Halaman 4: Notifikasi ─────────────────────────────────────────────────

class _NotificationPage extends ConsumerWidget {
  final Future<void> Function() onFinish;
  const _NotificationPage({required this.onFinish});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_outlined, size: 72, color: colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            'Pengingat Adzan',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Aktifkan notifikasi agar tidak melewatkan waktu sholat. '
            'Anda bisa mengatur per-sholat di Pengaturan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7), height: 1.5),
          ),
          const SizedBox(height: 48),
          FilledButton.icon(
            onPressed: () async {
              // Minta izin notifikasi dari OS
              // NotificationScheduler diinisialisasi di main.dart
              await onFinish();
            },
            icon: const Icon(Icons.notifications_active),
            label: const Text('Aktifkan Notifikasi'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onFinish,
            child: const Text('Lewati untuk Sekarang'),
          ),
        ],
      ),
    );
  }
}
