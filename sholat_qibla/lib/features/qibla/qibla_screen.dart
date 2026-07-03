import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// Tab 2 — Arah Kiblat.
///
/// Menampilkan kompas dengan indikator Ka'bah yang berputar
/// mengikuti sensor magnetometer. Dilengkapi:
/// - Gate kalibrasi (saat akurasi rendah)
/// - Indikator akurasi live
/// - Fallback untuk perangkat tanpa magnetometer
class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qiblaAsync = ref.watch(qiblaResultProvider);
    final compassAsync = ref.watch(compassProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Arah Kiblat'),
      ),
      body: qiblaAsync.when(
        data: (qibla) => compassAsync.when(
          data: (event) => _QiblaBody(
            qiblaBearing: qibla.bearingDegrees,
            distanceKm: qibla.distanceKm,
            event: event,
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => _QiblaFallback(
            qiblaBearing: qibla.bearingDegrees,
            distanceKm: qibla.distanceKm,
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, size: 48),
                const SizedBox(height: 16),
                const Text('Lokasi belum tersedia',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Berikan izin lokasi atau pilih kota manual di Pengaturan '
                  'untuk menghitung arah kiblat.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Body utama kompas kiblat.
class _QiblaBody extends StatelessWidget {
  final double qiblaBearing;
  final double distanceKm;
  final CompassEvent? event;

  const _QiblaBody({
    required this.qiblaBearing,
    required this.distanceKm,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    // Tidak ada magnetometer (event == null)
    if (event == null) {
      return _QiblaFallback(
          qiblaBearing: qiblaBearing, distanceKm: distanceKm);
    }

    final heading = event!.heading;
    if (heading == null) {
      return _QiblaFallback(
          qiblaBearing: qiblaBearing, distanceKm: distanceKm);
    }

    // Akurasi: Android mengembalikan 0-3, null = tidak tersedia
    final accuracy = event!.accuracy;
    final accuracyLevel = _accuracyLevel(accuracy);

    // Tampilkan gate kalibrasi jika akurasi rendah
    if (accuracyLevel == _AccuracyLevel.low) {
      return _CalibrationGate(
        qiblaBearing: qiblaBearing,
        distanceKm: distanceKm,
      );
    }

    return _CompassView(
      heading: heading,
      qiblaBearing: qiblaBearing,
      distanceKm: distanceKm,
      accuracyLevel: accuracyLevel,
    );
  }

  static _AccuracyLevel _accuracyLevel(double? accuracy) {
    if (accuracy == null) return _AccuracyLevel.medium;
    if (accuracy <= 1) return _AccuracyLevel.low;
    if (accuracy <= 2) return _AccuracyLevel.medium;
    return _AccuracyLevel.high;
  }
}

enum _AccuracyLevel { low, medium, high }

/// Tampilan kompas aktif dengan panah Ka'bah berputar.
class _CompassView extends StatelessWidget {
  final double heading;
  final double qiblaBearing;
  final double distanceKm;
  final _AccuracyLevel accuracyLevel;

  const _CompassView({
    required this.heading,
    required this.qiblaBearing,
    required this.distanceKm,
    required this.accuracyLevel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Sudut rotasi: Ka'bah tetap menunjuk ke Makkah meski ponsel berputar
    final rotationRad =
        (qiblaBearing - heading) * math.pi / 180.0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // ── Status akurasi ───────────────────────────────────────────
          _AccuracyBadge(level: accuracyLevel),
          const SizedBox(height: 32),

          // ── Kompas ───────────────────────────────────────────────────
          Expanded(
            child: Center(
              child: SizedBox(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lingkaran kompas
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                    ),
                    // Arah mata angin
                    _CompassLabels(heading: heading),
                    // Panah Ka'bah berputar
                    Transform.rotate(
                      angle: rotationRad,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mosque,
                              size: 32, color: colorScheme.primary),
                          Container(
                            width: 3,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withValues(alpha: 0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Titik tengah
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Info numerik ─────────────────────────────────────────────
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _InfoChip(
                icon: Icons.north,
                label: '${qiblaBearing.round()}° dari Utara',
              ),
              _InfoChip(
                icon: Icons.straighten,
                label: '${distanceKm.round()} km ke Makkah',
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Label arah mata angin di sekeliling kompas.
class _CompassLabels extends StatelessWidget {
  final double heading;
  const _CompassLabels({required this.heading});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(top: 8, child: Text('U', style: style)),
        Positioned(bottom: 8, child: Text('S', style: style)),
        Positioned(left: 8, child: Text('B', style: style)),
        Positioned(right: 8, child: Text('T', style: style)),
      ],
    );
  }
}

/// Badge status akurasi kompas.
class _AccuracyBadge extends StatelessWidget {
  final _AccuracyLevel level;
  const _AccuracyBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (level) {
      _AccuracyLevel.high   => ('Akurasi Tinggi', Colors.green),
      _AccuracyLevel.medium => ('Akurasi Sedang', Colors.orange),
      _AccuracyLevel.low    => ('Akurasi Rendah', Colors.red),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.radar, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Gate kalibrasi — tampil saat akurasi sensor magnetometer rendah.
class _CalibrationGate extends StatelessWidget {
  final double qiblaBearing;
  final double distanceKm;

  const _CalibrationGate({
    required this.qiblaBearing,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _AccuracyBadge(level: _AccuracyLevel.low),
          const SizedBox(height: 32),
          Icon(Icons.sync_problem, size: 80,
              color: colorScheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(height: 24),
          Text(
            'Kalibrasi Kompas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Text(
            'Gerakkan ponsel membentuk angka 8 di udara beberapa kali, lalu coba lagi.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 32),
          // Animasi angka 8 sederhana
          SizedBox(
            height: 80,
            child: _FigureEightAnimation(),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Sementara itu, arah kiblat:',
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 8),
          _InfoChip(
            icon: Icons.north,
            label: '${qiblaBearing.round()}° dari Utara',
          ),
        ],
      ),
    );
  }
}

/// Animasi indikator angka 8 sederhana (kalibrasi kompas).
class _FigureEightAnimation extends StatefulWidget {
  @override
  State<_FigureEightAnimation> createState() => _FigureEightAnimationState();
}

class _FigureEightAnimationState extends State<_FigureEightAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value * 2 * math.pi;
        final x = math.sin(t) * 30;
        final y = math.sin(t * 2) * 20;
        return Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(x, y),
              child: Icon(
                Icons.smartphone,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Fallback ketika perangkat tidak memiliki magnetometer.
class _QiblaFallback extends StatelessWidget {
  final double qiblaBearing;
  final double distanceKm;

  const _QiblaFallback({
    required this.qiblaBearing,
    required this.distanceKm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compass_calibration_outlined, size: 80,
              color: colorScheme.onSurface.withValues(alpha: 0.4)),
          const SizedBox(height: 24),
          Text(
            'Kompas Tidak Tersedia',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Perangkat tidak memiliki sensor kompas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 32),
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Arah Kiblat',
                    style: TextStyle(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${qiblaBearing.round()}°',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'dari Utara',
                    style: TextStyle(color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Gunakan kompas fisik atau aplikasi kompas lain, '
                    'lalu hadap ke ${qiblaBearing.round()}° dari Utara.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _InfoChip(
            icon: Icons.straighten,
            label: '${distanceKm.round()} km ke Makkah',
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurface),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
