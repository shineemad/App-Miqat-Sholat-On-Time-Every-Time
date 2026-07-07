import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_card.dart';
import '../today/prayer_display.dart';
import 'ramadhan_controller.dart';

/// Layar Mode Ramadhan: hitung mundur imsak/buka puasa, jadwal hari ini,
/// dan status hari Ramadhan (offline penuh).
class RamadhanScreen extends StatefulWidget {
  const RamadhanScreen({super.key, required this.controller});

  final RamadhanController controller;

  @override
  State<RamadhanScreen> createState() => _RamadhanScreenState();
}

class _RamadhanScreenState extends State<RamadhanScreen> {
  RamadhanInfo? _info;
  Object? _error;
  DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
      // Lewati tengah malam / peristiwa terlewat: muat ulang ringkasan.
      final info = _info;
      if (info != null && !_now.isBefore(info.nextEventTime)) _load();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final info = await widget.controller.loadInfo();
      if (!mounted) return;
      setState(() {
        _info = info;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mode Ramadhan')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Gagal memuat jadwal Ramadhan',
              style: AppTypography.textTheme.titleMedium),
        ),
      );
    }
    final info = _info;
    if (info == null) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    final remaining = info.nextEventTime.difference(_now);
    final isIftar = info.nextEvent == RamadhanEvent.iftar;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status Hijriah / hari Ramadhan.
        NeoCard(
          backgroundColor: AppColors.secondaryContainer,
          child: Row(
            children: [
              const Icon(Icons.brightness_3, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.isRamadhan
                          ? 'Ramadhan hari ke-${info.dayOfRamadhan}'
                          : '${info.daysUntilRamadhan} hari menuju Ramadhan',
                      style: AppTypography.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${info.hijri.formatId()} · ${info.city.name}',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Hero hitung mundur imsak/buka.
        Semantics(
          liveRegion: true,
          label:
              '${isIftar ? 'Buka puasa' : 'Imsak'} pukul ${PrayerDisplay.time(info.nextEventTime)}, ${PrayerDisplay.countdown(remaining)} lagi',
          child: ExcludeSemantics(
            child: NeoCard(
              active: true,
              highlighted: true,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(isIftar ? Icons.restaurant : Icons.alarm, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        isIftar ? 'Menuju Buka Puasa' : 'Menuju Imsak',
                        style: AppTypography.textTheme.labelLarge!
                            .copyWith(color: AppColors.onPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    PrayerDisplay.countdown(remaining),
                    style: AppTypography.textTheme.displayMedium!
                        .copyWith(color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'lagi · pukul ${PrayerDisplay.time(info.nextEventTime)}',
                    style: AppTypography.textTheme.bodyLarge!
                        .copyWith(color: AppColors.onPrimary),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Jadwal hari ini.
        _ScheduleRow(
          icon: Icons.alarm,
          label: 'Imsak',
          time: info.imsak,
          highlighted: !isIftar,
        ),
        const SizedBox(height: 12),
        _ScheduleRow(
          icon: Icons.wb_twilight,
          label: 'Subuh',
          time: info.fajr,
        ),
        const SizedBox(height: 12),
        _ScheduleRow(
          icon: Icons.restaurant,
          label: 'Buka Puasa (Maghrib)',
          time: info.maghrib,
          highlighted: isIftar,
        ),
        const SizedBox(height: 16),
        Text(
          'Imsak mengikuti konvensi Kemenag: 10 menit sebelum Subuh. '
          'Tanggal Hijriah adalah perkiraan tabular (±1 hari); ikuti '
          'penetapan resmi pemerintah.',
          style: AppTypography.textTheme.bodySmall,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.icon,
    required this.label,
    required this.time,
    this.highlighted = false,
  });

  final IconData icon;
  final String label;
  final DateTime time;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      highlighted: highlighted,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: AppTypography.textTheme.titleMedium),
          ),
          Text(
            PrayerDisplay.time(time),
            style: AppTypography.textTheme.titleMedium!
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
