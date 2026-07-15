import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_button.dart';
import '../../core/widgets/neo_card.dart';
import '../../core/widgets/neo_toggle.dart';
import '../../data/cities/city_repository.dart';
import '../../engine/models/calculation_method.dart';
import '../../engine/models/madhab.dart';
import '../../engine/models/prayer_times.dart';
import '../../notifications/models/notification_settings.dart';
import '../settings/widgets/city_picker.dart';
import 'onboarding_controller.dart';

/// Alur onboarding pertama kali (§3.1): welcome → lokasi → metode →
/// notifikasi. Menyimpan pilihan awal lalu memanggil [onFinish].
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.controller,
    required this.cityRepository,
    required this.notificationSettings,
    required this.onFinish,
  });

  final OnboardingController controller;
  final CityRepository cityRepository;
  final NotificationSettingsRepository notificationSettings;
  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;

  // Pilihan lokal.
  bool _useGps = true;
  String? _cityName;
  CalculationMethod _method = CalculationMethod.kemenag;
  Madhab _madhab = Madhab.shafi;
  bool _notifOn = true;

  static const _lastStep = 3;

  Future<void> _next() async {
    if (_step < _lastStep) {
      setState(() => _step++);
      widget.controller.next();
    } else {
      await _finish();
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      widget.controller.previous();
    }
  }

  Future<void> _finish() async {
    // Persist pilihan.
    if (_useGps) {
      await widget.controller.enableGps();
    }
    await widget.controller.chooseMethod(_method);
    await widget.controller.chooseMadhab(_madhab);

    final base = widget.notificationSettings.load();
    await widget.notificationSettings.save(
      base.copyWith(
        enabledPrayers:
            _notifOn ? NotificationSettings.defaultEnabled : <Prayer>{},
      ),
    );

    await widget.controller.complete();
    widget.onFinish();
  }

  Future<void> _pickCity() async {
    final id = await showCityPicker(context,
        repository: widget.cityRepository);
    if (id == null) return;
    await widget.controller.chooseCity(id);
    final city = await widget.cityRepository.getById(id);
    if (!mounted) return;
    setState(() {
      _useGps = false;
      _cityName = city?.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _StepIndicator(current: _step, total: _lastStep + 1),
              const SizedBox(height: 24),
              Expanded(child: _buildStep()),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (_step > 0)
                    NeoButton(
                      label: 'Kembali',
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.onSurface,
                      onPressed: _back,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label: _step == _lastStep ? 'Selesai' : 'Lanjut',
                      icon: _step == _lastStep
                          ? Icons.check
                          : Icons.arrow_forward,
                      expanded: true,
                      onPressed: _next,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
        0 => const _WelcomeStep(),
        1 => _LocationStep(
            useGps: _useGps,
            cityName: _cityName,
            onUseGps: () => setState(() {
              _useGps = true;
              _cityName = null;
            }),
            onPickCity: _pickCity,
          ),
        2 => _MethodStep(
            method: _method,
            madhab: _madhab,
            onMethod: (m) => setState(() => _method = m),
            onMadhab: (m) => setState(() => _madhab = m),
          ),
        _ => _NotifStep(
            value: _notifOn,
            onChanged: (v) => setState(() => _notifOn = v),
          ),
      };
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: i <= current
                    ? AppColors.primary
                    : AppColors.surfaceContainerHighest,
                border: Border.all(color: AppColors.outline, width: 2),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            border: AppShapes.hardBorder,
            borderRadius: AppShapes.card,
          ),
          child: Icon(Icons.mosque, size: 48, color: AppColors.onPrimary),
        ),
        const SizedBox(height: 24),
        Text(
          'MU-Qibla',
          style: AppTypography.textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Sholat On Time, Every Time. Jadwal sholat akurat & arah kiblat, '
          'bekerja penuh secara offline di perangkat Anda.',
          style: AppTypography.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    required this.useGps,
    required this.cityName,
    required this.onUseGps,
    required this.onPickCity,
  });

  final bool useGps;
  final String? cityName;
  final VoidCallback onUseGps;
  final VoidCallback onPickCity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lokasi', style: AppTypography.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          'Untuk menghitung waktu sholat & arah kiblat. Lokasi tidak pernah '
          'meninggalkan perangkat.',
          style: AppTypography.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        NeoCard(
          active: useGps,
          highlighted: useGps,
          onTap: onUseGps,
          child: Row(
            children: [
              Icon(Icons.gps_fixed,
                  color: useGps ? AppColors.onPrimary : AppColors.onSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Gunakan Lokasi (GPS)',
                    style: AppTypography.textTheme.titleMedium!.copyWith(
                        color: useGps
                            ? AppColors.onPrimary
                            : AppColors.onSurface)),
              ),
              if (useGps) Icon(Icons.check, color: AppColors.onPrimary),
            ],
          ),
        ),
        const SizedBox(height: 12),
        NeoCard(
          active: !useGps,
          highlighted: !useGps,
          onTap: onPickCity,
          child: Row(
            children: [
              Icon(Icons.location_city,
                  color: !useGps ? AppColors.onPrimary : AppColors.onSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cityName ?? 'Pilih Kota Manual',
                  style: AppTypography.textTheme.titleMedium!.copyWith(
                      color:
                          !useGps ? AppColors.onPrimary : AppColors.onSurface),
                ),
              ),
              Icon(Icons.chevron_right,
                  color: !useGps ? AppColors.onPrimary : AppColors.onSurface),
            ],
          ),
        ),
      ],
    );
  }
}

class _MethodStep extends StatelessWidget {
  const _MethodStep({
    required this.method,
    required this.madhab,
    required this.onMethod,
    required this.onMadhab,
  });

  final CalculationMethod method;
  final Madhab madhab;
  final ValueChanged<CalculationMethod> onMethod;
  final ValueChanged<Madhab> onMadhab;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text('Metode Perhitungan',
            style: AppTypography.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Default Kemenag untuk Indonesia. Bisa diubah kapan saja.',
            style: AppTypography.textTheme.bodyMedium),
        const SizedBox(height: 16),
        for (final m in CalculationMethod.values) ...[
          NeoCard(
            active: m == method,
            highlighted: m == method,
            onTap: () => onMethod(m),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(m.label,
                      style: AppTypography.textTheme.titleMedium!.copyWith(
                          color: m == method
                              ? AppColors.onPrimary
                              : AppColors.onSurface)),
                ),
                if (m == method)
                  Icon(Icons.check, color: AppColors.onPrimary),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 8),
        Text('Madzhab Ashar', style: AppTypography.textTheme.titleSmall),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _PickChip(
                label: "Syafi'i",
                selected: madhab == Madhab.shafi,
                onTap: () => onMadhab(Madhab.shafi),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PickChip(
                label: 'Hanafi',
                selected: madhab == Madhab.hanafi,
                onTap: () => onMadhab(Madhab.hanafi),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NotifStep extends StatelessWidget {
  const _NotifStep({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notifikasi Adzan',
            style: AppTypography.textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text('Ingatkan saya saat waktu sholat tiba. Bisa diatur per-sholat '
            'nanti di Pengaturan.',
            style: AppTypography.textTheme.bodyMedium),
        const SizedBox(height: 20),
        NeoCard(
          active: value,
          highlighted: value,
          child: Row(
            children: [
              Icon(Icons.notifications_active_outlined,
                  color: value ? AppColors.onPrimary : AppColors.onSurface),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Aktifkan notifikasi 5 waktu',
                    style: AppTypography.textTheme.titleMedium!.copyWith(
                        color: value
                            ? AppColors.onPrimary
                            : AppColors.onSurface)),
              ),
              NeoToggle(
                value: value,
                semanticLabel: 'Aktifkan notifikasi',
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PickChip extends StatelessWidget {
  const _PickChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary : AppColors.surfaceContainerLowest,
          border: AppShapes.hardBorder,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
