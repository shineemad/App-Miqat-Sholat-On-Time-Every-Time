import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_card.dart';
import '../../core/widgets/neo_toggle.dart';
import '../../data/cities/city_repository.dart';
import '../../engine/models/calculation_method.dart';
import '../../engine/models/madhab.dart';
import '../../engine/models/prayer_times.dart';
import '../../notifications/adhan_player.dart';
import '../../notifications/models/notification_settings.dart';
import 'settings_controller.dart';
import 'widgets/city_picker.dart';

/// Layar Pengaturan (§3.6): dikelompokkan (Sholat, Notifikasi, Lokasi,
/// Privasi, Tentang) — bukan satu daftar datar.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.cityRepository,
    this.appVersion = '0.1.0',
  });

  final SettingsController controller;
  final CityRepository cityRepository;
  final String appVersion;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsSnapshot? _snapshot;
  bool _loading = true;

  final AdhanPlayer _adhanPlayer = AdhanPlayer();
  bool _adhanPlaying = false;

  static const _prayerOrder = [
    Prayer.fajr,
    Prayer.dhuhr,
    Prayer.asr,
    Prayer.maghrib,
    Prayer.isha,
  ];
  static const _prayerLabels = {
    Prayer.fajr: 'Subuh',
    Prayer.dhuhr: 'Dzuhur',
    Prayer.asr: 'Ashar',
    Prayer.maghrib: 'Maghrib',
    Prayer.isha: 'Isya',
  };

  @override
  void initState() {
    super.initState();
    _reload();
    _adhanPlayer.onStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _adhanPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _adhanPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAdhanPreview() async {
    if (_adhanPlaying) {
      await _adhanPlayer.stop();
    } else {
      await _adhanPlayer.play();
    }
  }

  Future<void> _reload() async {
    final snapshot = await widget.controller.load();
    if (!mounted) return;
    setState(() {
      _snapshot = snapshot;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SafeArea(
        child: _loading || _snapshot == null
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSholat(_snapshot!),
                  const SizedBox(height: 20),
                  _buildNotifikasi(_snapshot!),
                  const SizedBox(height: 20),
                  _buildLokasi(_snapshot!),
                  const SizedBox(height: 20),
                  _buildPrivasi(),
                  const SizedBox(height: 20),
                  _buildTentang(),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  // ---------------------------------------------------------------- Sholat

  Widget _buildSholat(SettingsSnapshot s) {
    return _Group(
      title: 'Sholat',
      children: [
        _RowTile(
          icon: Icons.calculate_outlined,
          title: 'Metode perhitungan',
          trailing: s.method.label,
          onTap: () => _pickMethod(s.method),
        ),
        const _Divider(),
        _RowTile(
          icon: Icons.schedule_outlined,
          title: 'Madzhab Ashar',
          child: _MadhabSelector(
            value: s.madhab,
            onChanged: (m) async {
              await widget.controller.setMadhab(m);
              await _reload();
            },
          ),
        ),
      ],
    );
  }

  Future<void> _pickMethod(CalculationMethod current) async {
    final selected = await showModalBottomSheet<CalculationMethod>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MethodSheet(current: current),
    );
    if (selected != null) {
      await widget.controller.setMethod(selected);
      await _reload();
    }
  }

  Future<void> _pickPreAdhanMinutes(int current) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PreAdhanSheet(current: current),
    );
    if (selected != null) {
      await widget.controller.setPreAdhanMinutes(selected);
      await _reload();
    }
  }

  // ----------------------------------------------------------- Notifikasi

  Widget _buildNotifikasi(SettingsSnapshot s) {
    final notif = s.notifications;
    return _Group(
      title: 'Notifikasi',
      children: [
        _RowTile(
          icon: Icons.volume_up_outlined,
          title: 'Mode suara',
          child: _AdhanModeSelector(
            value: notif.mode,
            onChanged: (m) async {
              await widget.controller.setAdhanMode(m);
              await _reload();
            },
          ),
        ),
        const _Divider(),
        _RowTile(
          icon: _adhanPlaying ? Icons.stop_circle : Icons.play_circle_outline,
          title: 'Dengar adzan',
          subtitle: _adhanPlaying ? 'Sedang memutar…' : 'Pratinjau suara adzan penuh',
          onTap: _toggleAdhanPreview,
        ),
        const _Divider(),
        _RowTile(
          icon: Icons.alarm,
          title: 'Pengingat pra-adzan',
          subtitle: 'Alarm sebelum waktu sholat',
          child: NeoToggle(
            value: notif.preAdhanEnabled,
            semanticLabel: 'Pengingat pra-adzan',
            onChanged: (v) async {
              await widget.controller.setPreAdhanEnabled(v);
              await _reload();
            },
          ),
        ),
        if (notif.preAdhanEnabled) ...[
          const _Divider(),
          _RowTile(
            icon: Icons.timer_outlined,
            title: 'Jeda pengingat',
            trailing: '${notif.preAdhanMinutes} menit',
            onTap: () => _pickPreAdhanMinutes(notif.preAdhanMinutes),
          ),
        ],
        const _Divider(),
        for (final prayer in _prayerOrder) ...[
          _RowTile(
            icon: Icons.notifications_outlined,
            title: _prayerLabels[prayer]!,
            child: NeoToggle(
              value: notif.isEnabled(prayer),
              semanticLabel: 'Notifikasi ${_prayerLabels[prayer]}',
              onChanged: (v) async {
                await widget.controller.togglePrayerNotification(prayer, v);
                await _reload();
              },
            ),
          ),
          if (prayer != _prayerOrder.last) const _Divider(),
        ],
      ],
    );
  }

  // --------------------------------------------------------------- Lokasi

  Widget _buildLokasi(SettingsSnapshot s) {
    return _Group(
      title: 'Lokasi',
      children: [
        _RowTile(
          icon: Icons.gps_fixed,
          title: 'Gunakan GPS',
          subtitle: 'Deteksi kota otomatis dari lokasi',
          child: NeoToggle(
            value: s.useGps,
            semanticLabel: 'Gunakan GPS',
            onChanged: (v) async {
              await widget.controller.setUseGps(v);
              await _reload();
            },
          ),
        ),
        const _Divider(),
        _RowTile(
          icon: Icons.location_city,
          title: 'Kota terpilih',
          trailing: s.selectedCity?.name ?? '—',
          onTap: () async {
            final id = await showCityPicker(context,
                repository: widget.cityRepository);
            if (id != null) {
              await widget.controller.selectCity(id);
              await _reload();
            }
          },
        ),
      ],
    );
  }

  // -------------------------------------------------------------- Privasi

  Widget _buildPrivasi() {
    return _Group(
      title: 'Privasi',
      children: [
        NeoCard(
          backgroundColor: AppColors.secondaryContainer,
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data tidak meninggalkan perangkat',
                        style: AppTypography.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Tanpa akun, tanpa server. Lokasi & preferensi diproses '
                      'sepenuhnya di perangkat Anda (offline-first).',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------- Tentang

  Widget _buildTentang() {
    return _Group(
      title: 'Tentang',
      children: [
        _RowTile(
          icon: Icons.info_outline,
          title: 'Miqat — Sholat On Time',
          trailing: 'v${widget.appVersion}',
        ),
        const _Divider(),
        _RowTile(
          icon: Icons.graphic_eq,
          title: 'Suara adzan',
          subtitle:
              'The Adhan oleh Atcovi (Wikimedia Commons), CC BY-SA 4.0',
        ),
        const _Divider(),
        _RowTile(
          icon: Icons.replay,
          title: 'Ulangi Onboarding',
          subtitle: 'Tampilkan lagi alur perkenalan',
          onTap: _restartOnboarding,
        ),
      ],
    );
  }

  Future<void> _restartOnboarding() async {
    await widget.controller.resetOnboarding();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (_) => false);
  }
}

// ============================================================ sub-widgets

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: AppTypography.textTheme.titleSmall),
        ),
        NeoCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _RowTile extends StatelessWidget {
  const _RowTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.child,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.textTheme.titleMedium),
                  if (subtitle != null)
                    Text(subtitle!, style: AppTypography.textTheme.bodySmall),
                ],
              ),
            ),
            if (child != null)
              child!
            else if (trailing != null) ...[
              Flexible(
                child: Text(
                  trailing!,
                  style: AppTypography.textTheme.labelLarge!
                      .copyWith(color: AppColors.primary),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: AppColors.surfaceContainerHighest,
      );
}

class _MadhabSelector extends StatelessWidget {
  const _MadhabSelector({required this.value, required this.onChanged});
  final Madhab value;
  final ValueChanged<Madhab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SegChip(
          label: "Syafi'i",
          selected: value == Madhab.shafi,
          onTap: () => onChanged(Madhab.shafi),
        ),
        const SizedBox(width: 6),
        _SegChip(
          label: 'Hanafi',
          selected: value == Madhab.hanafi,
          onTap: () => onChanged(Madhab.hanafi),
        ),
      ],
    );
  }
}

class _AdhanModeSelector extends StatelessWidget {
  const _AdhanModeSelector({required this.value, required this.onChanged});
  final AdhanMode value;
  final ValueChanged<AdhanMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final mode in AdhanMode.values) ...[
          _SegChip(
            label: switch (mode) {
              AdhanMode.adhan => 'Adzan',
              AdhanMode.silent => 'Senyap',
              AdhanMode.vibrate => 'Getar',
            },
            selected: value == mode,
            onTap: () => onChanged(mode),
          ),
          if (mode != AdhanMode.values.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _SegChip extends StatelessWidget {
  const _SegChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.primary : AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outline, width: 2),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: AppTypography.textTheme.labelMedium!.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Modal daftar metode perhitungan.
class _MethodSheet extends StatelessWidget {
  const _MethodSheet({required this.current});
  final CalculationMethod current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: AppShapes.hardBorder,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Metode Perhitungan',
                  style: AppTypography.textTheme.titleLarge),
            ),
            for (final method in CalculationMethod.values)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: NeoCard(
                  active: method == current,
                  highlighted: method == current,
                  onTap: () => Navigator.of(context).pop(method),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(method.label,
                            style: AppTypography.textTheme.titleMedium!.copyWith(
                              color: method == current
                                  ? AppColors.onPrimary
                                  : AppColors.onSurface,
                            )),
                      ),
                      if (method == current)
                        const Icon(Icons.check, color: AppColors.onPrimary),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Modal pemilih jeda pengingat pra-adzan (menit).
class _PreAdhanSheet extends StatelessWidget {
  const _PreAdhanSheet({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: AppShapes.hardBorder,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Jeda Pengingat',
                  style: AppTypography.textTheme.titleLarge),
            ),
            for (final minutes in NotificationSettings.preAdhanOptions)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: NeoCard(
                  active: minutes == current,
                  highlighted: minutes == current,
                  onTap: () => Navigator.of(context).pop(minutes),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('$minutes menit sebelum adzan',
                            style: AppTypography.textTheme.titleMedium!.copyWith(
                              color: minutes == current
                                  ? AppColors.onPrimary
                                  : AppColors.onSurface,
                            )),
                      ),
                      if (minutes == current)
                        const Icon(Icons.check, color: AppColors.onPrimary),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
