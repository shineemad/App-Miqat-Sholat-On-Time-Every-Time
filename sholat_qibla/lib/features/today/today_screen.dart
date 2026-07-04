import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_button.dart';
import '../../core/widgets/neo_card.dart';
import '../../engine/models/prayer_times.dart';
import '../hub/hijri_calendar.dart';
import 'today_controller.dart';
import 'widgets/next_prayer_hero.dart';
import 'widgets/prayer_time_card.dart';

/// Layar hero aplikasi: Beranda (Today).
///
/// Menjawab pertanyaan utama pengguna dalam < 2 detik: "Sholat berikutnya
/// apa & berapa lama lagi?" (§3.2). Meng-orkestrasi [TodayController] untuk
/// memuat data dan menjalankan hitung mundur per detik.
class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    required this.controller,
    this.onOpenQibla,
    this.clock,
  });

  final TodayController controller;
  final VoidCallback? onOpenQibla;

  /// Sumber waktu (untuk test). Default [DateTime.now].
  final DateTime Function()? clock;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  TodaySummary? _summary;
  Object? _error;
  bool _loading = true;
  bool _prayedMarked = false;
  Timer? _ticker;

  DateTime get _now => (widget.clock ?? DateTime.now)();

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await widget.controller.loadToday(now: _now);
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _loading = false;
        _prayedMarked = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _onTick() {
    final summary = _summary;
    if (summary == null) return;
    final next = summary.nextPrayerTime;
    // Bila waktu sholat berikutnya telah tiba, muat ulang jadwal.
    if (next != null && !_now.isBefore(next)) {
      _load();
    } else {
      setState(() {}); // perbarui hitung mundur
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miqat'),
        actions: [
          IconButton(
            onPressed: widget.onOpenQibla,
            icon: const Icon(Icons.explore_outlined),
            tooltip: 'Arah Kiblat',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          color: AppColors.primary,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading && _summary == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null && _summary == null) {
      return _ErrorView(onRetry: _load);
    }

    final summary = _summary!;
    final times = summary.prayerTimes;
    final next = summary.nextPrayer;
    final current = summary.currentPrayer;
    final remaining =
        summary.nextPrayerTime?.difference(_now) ?? Duration.zero;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DateLocationBar(summary: summary, now: _now),
        const SizedBox(height: 16),
        NextPrayerHero(
          prayer: next,
          time: summary.nextPrayerTime,
          remaining: next == null ? null : remaining,
        ),
        const SizedBox(height: 16),
        ..._prayerRows(times, current, next),
        const SizedBox(height: 16),
        NeoButton(
          label: _prayedMarked ? 'Sudah ditandai' : 'Sudah sholat',
          icon: _prayedMarked ? Icons.check_circle : Icons.check,
          expanded: true,
          backgroundColor:
              _prayedMarked ? AppColors.secondary : AppColors.outline,
          foregroundColor:
              _prayedMarked ? AppColors.onSecondary : AppColors.onPrimary,
          onPressed:
              _prayedMarked ? null : () => setState(() => _prayedMarked = true),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _prayerRows(
      PrayerTimes times, Prayer? current, Prayer? next) {
    const order = [
      Prayer.fajr,
      Prayer.dhuhr,
      Prayer.asr,
      Prayer.maghrib,
      Prayer.isha,
    ];
    return [
      for (final prayer in order) ...[
        PrayerTimeCard(
          prayer: prayer,
          time: times.timeFor(prayer),
          isActive: prayer == current,
          isNext: prayer == next,
        ),
        const SizedBox(height: 12),
      ],
    ];
  }
}

/// Bar tanggal (Masehi + Hijriah) & lokasi dengan badge sumber/offline.
class _DateLocationBar extends StatelessWidget {
  const _DateLocationBar({required this.summary, required this.now});

  final TodaySummary summary;
  final DateTime now;

  static const _weekdays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromGregorian(now);
    final gregorian =
        '${_weekdays[now.weekday - 1]}, ${now.day} ${_months[now.month - 1]} ${now.year}';

    return NeoCard(
      backgroundColor: AppColors.surfaceContainerLowest,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(gregorian, style: AppTypography.textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(hijri.formatId(), style: AppTypography.textTheme.bodyMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  summary.city.name,
                  style: AppTypography.textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _SourceBadge(source: summary.locationSource),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.source});

  final LocationSource source;

  @override
  Widget build(BuildContext context) {
    final (label, color, onColor) = switch (source) {
      LocationSource.gps => ('GPS', AppColors.secondary, AppColors.onSecondary),
      LocationSource.manualCity =>
        ('Manual', AppColors.tertiary, AppColors.onTertiary),
      LocationSource.fallback =>
        ('Default', AppColors.surfaceContainerHigh, AppColors.onSurface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.outline, width: 2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: AppTypography.textTheme.labelSmall!
            .copyWith(color: onColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 80),
        NeoCard(
          highlighted: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline, size: 28),
              const SizedBox(height: 8),
              Text('Gagal memuat jadwal',
                  style: AppTypography.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Periksa lokasi atau kota terpilih, lalu coba lagi.',
                  style: AppTypography.textTheme.bodyMedium),
              const SizedBox(height: 16),
              NeoButton(label: 'Coba Lagi', onPressed: onRetry),
            ],
          ),
        ),
      ],
    );
  }
}
