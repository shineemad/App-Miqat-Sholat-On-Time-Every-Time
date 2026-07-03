import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/time_utils.dart';
import '../../engine/models/prayer_time_result.dart';
import '../../features/qibla/qibla_screen.dart';

/// Tab 1 — Beranda (Today).
///
/// Layar hero yang menjawab pertanyaan utama dalam < 2 detik:
/// "Sholat berikutnya apa dan berapa lama lagi?"
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  late Timer _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Ticker setiap detik untuk memperbarui countdown
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final prayerAsync = ref.watch(prayerTimesProvider);
    final locationAsync = ref.watch(locationInfoProvider);
    final hijriAsync = ref.watch(hijriDateProvider);
    final markedAsync = ref.watch(markedPrayedProvider);

    return Scaffold(
      appBar: AppBar(
        title: locationAsync.when(
          data: (loc) => Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  loc.displayLabel,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (loc.mode.name == 'manual')
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Icon(Icons.edit_location_outlined, size: 14),
                ),
            ],
          ),
          loading: () => const Text('Memuat lokasi...'),
          error: (_, __) => const Text('Lokasi tidak tersedia'),
        ),
        actions: [
          // Badge offline
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off, size: 12, color: colorScheme.onSurface),
                const SizedBox(width: 4),
                Text('Offline', style: TextStyle(fontSize: 11, color: colorScheme.onSurface)),
              ],
            ),
          ),
          // Akses cepat Qibla
          IconButton(
            icon: const Icon(Icons.explore_outlined),
            tooltip: 'Arah Kiblat',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QiblaScreen()),
            ),
          ),
        ],
      ),
      body: prayerAsync.when(
        data: (result) => _TodayContent(
          result: result,
          now: _now,
          hijriAsync: hijriAsync,
          markedAsync: markedAsync,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(error: e.toString()),
      ),
    );
  }
}

class _TodayContent extends ConsumerWidget {
  final PrayerTimeResult result;
  final DateTime now;
  final AsyncValue hijriAsync;
  final AsyncValue<Set<String>> markedAsync;

  const _TodayContent({
    required this.result,
    required this.now,
    required this.hijriAsync,
    required this.markedAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final next = result.nextPrayer(now);
    final countdown = result.countdown(now);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Tanggal ───────────────────────────────────────────────────
        _DateCard(hijriAsync: hijriAsync, now: now),
        const SizedBox(height: 16),

        // ── Hero: sholat berikutnya + countdown ───────────────────────
        _HeroCard(
          next: next,
          countdown: countdown,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 16),

        // ── Daftar 5 waktu sholat ─────────────────────────────────────
        Card(
          child: Column(
            children: result.prayers.map((prayer) {
              final isActive = next?.name == prayer.name;
              return _PrayerRow(
                name: prayer.name,
                time: prayer.time,
                isActive: isActive,
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // ── Tombol Mark as Prayed ─────────────────────────────────────
        if (next != null)
          markedAsync.when(
            data: (marked) => _MarkPrayedButton(
              prayerName: next.name,
              isMarked: marked.contains(next.name),
              ref: ref,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class _DateCard extends StatelessWidget {
  final AsyncValue hijriAsync;
  final DateTime now;

  const _DateCard({required this.hijriAsync, required this.now});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          formatDateId(now),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        hijriAsync.when(
          data: (h) => Text(
            h.fullDisplay,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final ({String name, DateTime time})? next;
  final Duration? countdown;
  final ColorScheme colorScheme;

  const _HeroCard({
    required this.next,
    required this.countdown,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Column(
          children: [
            Text(
              'Sholat Berikutnya',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              next?.name ?? 'Selesai',
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (next != null) ...[
              Text(
                formatTime(next!.time),
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                countdown != null ? formatCountdown(countdown!) : '--',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'lagi',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ] else
              Text(
                'Semua sholat selesai',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String name;
  final DateTime time;
  final bool isActive;

  const _PrayerRow({
    required this.name,
    required this.time,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: isActive
          ? BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: ListTile(
        dense: true,
        leading: isActive
            ? Icon(Icons.arrow_right, color: colorScheme.primary)
            : const SizedBox(width: 24),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? colorScheme.primary : null,
          ),
        ),
        trailing: Text(
          formatTime(time),
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontFeatures: const [FontFeature.tabularFigures()],
            color: isActive ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _MarkPrayedButton extends StatelessWidget {
  final String prayerName;
  final bool isMarked;
  final WidgetRef ref;

  const _MarkPrayedButton({
    required this.prayerName,
    required this.isMarked,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: () async {
        final prefsAsync = ref.read(appPreferencesProvider);
        final prefs = prefsAsync.valueOrNull;
        if (prefs == null) return;
        final today = DateTime.now();
        if (isMarked) {
          await prefs.unmarkPrayed(prayerName, today);
        } else {
          await prefs.markPrayed(prayerName, today);
        }
        ref.invalidate(markedPrayedProvider);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isMarked ? Icons.check_circle : Icons.check_circle_outline),
          const SizedBox(width: 8),
          Text(isMarked
              ? '$prayerName — Sudah sholat ✓'
              : 'Tandai sudah sholat $prayerName'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            const Text('Gagal memuat waktu sholat',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 16),
            const Text(
              'Pastikan izin lokasi diberikan atau pilih kota manual di Pengaturan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
