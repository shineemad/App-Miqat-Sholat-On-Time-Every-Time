import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_card.dart';
import '../qibla_compass_service.dart';

/// Chip indikator akurasi kompas: Tinggi / Sedang / Rendah.
class AccuracyBadge extends StatelessWidget {
  const AccuracyBadge({super.key, required this.accuracy});

  final CompassAccuracy accuracy;

  @override
  Widget build(BuildContext context) {
    final (label, color, onColor) = switch (accuracy) {
      CompassAccuracy.high =>
        ('Akurasi Tinggi', AppColors.secondary, AppColors.onSecondary),
      CompassAccuracy.medium =>
        ('Akurasi Sedang', AppColors.tertiary, AppColors.onTertiary),
      CompassAccuracy.low =>
        ('Akurasi Rendah', AppColors.primary, AppColors.onPrimary),
      CompassAccuracy.unknown =>
        ('Akurasi Tak Diketahui', AppColors.surfaceContainerHigh,
            AppColors.onSurface),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: AppColors.outline, width: 2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sensors, size: 16, color: onColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.textTheme.labelMedium!
                .copyWith(color: onColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Gate kalibrasi (§3.3): tampil saat akurasi rendah/tak diketahui.
///
/// Menampilkan animasi gerakan angka 8 + instruksi, alih-alih menampilkan
/// jarum "yakin" yang bisa menyesatkan.
class CalibrationGate extends StatefulWidget {
  const CalibrationGate({super.key});

  @override
  State<CalibrationGate> createState() => _CalibrationGateState();
}

class _CalibrationGateState extends State<CalibrationGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      highlighted: true,
      backgroundColor: AppColors.primaryContainer,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 90,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => CustomPaint(
                size: const Size(140, 90),
                painter: _Figure8Painter(_controller.value),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Akurasi rendah — kalibrasi dulu',
            style: AppTypography.textTheme.titleMedium!
                .copyWith(color: AppColors.onPrimaryContainer),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Gerakkan perangkat membentuk angka 8 beberapa kali '
            'hingga akurasi meningkat.',
            style: AppTypography.textTheme.bodyMedium!
                .copyWith(color: AppColors.onPrimaryContainer),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Menggambar lintasan angka 8 (lemniscate) dengan titik bergerak.
class _Figure8Painter extends CustomPainter {
  _Figure8Painter(this.t);

  /// Progres animasi 0..1.
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final a = size.width / 2 - 10;
    final b = size.height / 2 - 8;

    final path = Path();
    for (var i = 0; i <= 100; i++) {
      final theta = (i / 100) * 2 * 3.1415926;
      final x = cx + a * _sin(theta);
      final y = cy + b * _sin(theta) * _cos(theta);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.outline,
    );

    // Titik bergerak.
    final theta = t * 2 * 3.1415926;
    final dot = Offset(cx + a * _sin(theta), cy + b * _sin(theta) * _cos(theta));
    canvas.drawCircle(dot, 7, Paint()..color = AppColors.primary);
    canvas.drawCircle(
      dot,
      7,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.outline,
    );
  }

  static double _sin(double x) => math.sin(x);
  static double _cos(double x) => math.cos(x);

  @override
  bool shouldRepaint(covariant _Figure8Painter oldDelegate) =>
      oldDelegate.t != t;
}
