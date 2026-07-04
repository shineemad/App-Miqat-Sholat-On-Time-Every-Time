import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_button.dart';
import '../../core/widgets/neo_card.dart';
import '../../core/utils/compass_utils.dart';
import 'qibla_compass_service.dart';
import 'qibla_controller.dart';
import 'widgets/compass_dial.dart';
import 'widgets/qibla_status.dart';

/// Layar Arah Kiblat (§3.3).
///
/// Menampilkan kompas dengan penanda Ka'bah, gate kalibrasi saat akurasi
/// rendah, indikator akurasi live, dan fallback derajat untuk perangkat
/// tanpa magnetometer.
class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key, required this.controller});

  final QiblaController controller;

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  QiblaInfo? _info;
  bool _hasCompass = true;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    widget.controller.reset();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final info = await widget.controller.loadInfo();
      final hasCompass = await widget.controller.hasCompass();
      if (!mounted) return;
      setState(() {
        _info = info;
        _hasCompass = hasCompass;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Arah Kiblat')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null || _info == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: NeoCard(
            highlighted: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error_outline, size: 28),
                const SizedBox(height: 8),
                Text('Gagal memuat arah kiblat',
                    style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 16),
                NeoButton(label: 'Coba Lagi', onPressed: _load),
              ],
            ),
          ),
        ),
      );
    }

    final info = _info!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _LocationSummary(info: info),
        const SizedBox(height: 16),
        if (!_hasCompass)
          _NoSensorFallback(info: info)
        else
          _CompassSection(controller: widget.controller, info: info),
        const SizedBox(height: 16),
        _QiblaFacts(info: info),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// Kompas live (stream QiblaState) + gate kalibrasi.
class _CompassSection extends StatelessWidget {
  const _CompassSection({required this.controller, required this.info});

  final QiblaController controller;
  final QiblaInfo info;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblaState?>(
      stream: controller.watch(info.location),
      builder: (context, snapshot) {
        final state = snapshot.data;

        if (state == null) {
          return NeoCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text('Membaca sensor kompas…',
                    style: AppTypography.textTheme.bodyMedium),
              ],
            ),
          );
        }

        if (state.needsCalibration) {
          return Column(
            children: [
              const CalibrationGate(),
              const SizedBox(height: 12),
              Center(child: AccuracyBadge(accuracy: state.accuracy)),
            ],
          );
        }

        return NeoCard(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              CompassDial(
                heading: state.deviceHeading,
                relativeAngle: state.relativeAngle,
                isFacingQibla: state.isFacingQibla,
              ),
              const SizedBox(height: 20),
              if (state.isFacingQibla)
                Text(
                  'Tepat menghadap kiblat',
                  style: AppTypography.textTheme.titleMedium!
                      .copyWith(color: AppColors.secondary),
                )
              else
                Text(
                  state.relativeAngle > 0
                      ? 'Putar ke kanan ${state.relativeAngle.abs().round()}°'
                      : 'Putar ke kiri ${state.relativeAngle.abs().round()}°',
                  style: AppTypography.textTheme.titleMedium,
                ),
              const SizedBox(height: 12),
              AccuracyBadge(accuracy: state.accuracy),
            ],
          ),
        );
      },
    );
  }
}

/// Fallback perangkat tanpa magnetometer: tampilkan derajat + instruksi.
class _NoSensorFallback extends StatelessWidget {
  const _NoSensorFallback({required this.info});

  final QiblaInfo info;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      highlighted: true,
      backgroundColor: AppColors.tertiaryContainer,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore_off_outlined, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Kompas tidak tersedia',
                    style: AppTypography.textTheme.titleMedium),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Perangkat ini tidak memiliki sensor kompas. Arahkan diri Anda '
            '${info.bearing.round()}° dari Utara sejati '
            '(${CompassUtils.cardinalLabel(info.bearing)}) menggunakan kompas '
            'fisik atau matahari.',
            style: AppTypography.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LocationSummary extends StatelessWidget {
  const _LocationSummary({required this.info});

  final QiblaInfo info;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(info.city.name,
                style: AppTypography.textTheme.titleMedium,
                overflow: TextOverflow.ellipsis),
          ),
          Text(
            'Ka\'bah',
            style: AppTypography.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Fakta kiblat: derajat dari Utara & jarak ke Makkah.
class _QiblaFacts extends StatelessWidget {
  const _QiblaFacts({required this.info});

  final QiblaInfo info;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sudut kiblat',
                    style: AppTypography.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '${info.bearing.toStringAsFixed(1)}°',
                  style: AppTypography.textTheme.headlineSmall,
                ),
                Text(CompassUtils.cardinalLabel(info.bearing),
                    style: AppTypography.textTheme.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: NeoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jarak ke Makkah',
                    style: AppTypography.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '${info.distanceKm.round()} km',
                  style: AppTypography.textTheme.headlineSmall,
                ),
                Text('garis lurus',
                    style: AppTypography.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
