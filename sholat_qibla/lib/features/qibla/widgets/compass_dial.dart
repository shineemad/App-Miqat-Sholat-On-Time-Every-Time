import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Piringan kompas Neo-Brutalist dengan penanda Ka'bah.
///
/// - [heading]: arah hadap perangkat (derajat, 0 = utara). Piringan mata
///   angin diputar berlawanan agar Utara tetap menunjuk ke atas relatif bumi.
/// - [relativeAngle]: sudut kiblat relatif arah hadap; jarum Ka'bah diputar
///   sebesar nilai ini (0 = tepat di atas / menghadap kiblat).
/// - [isFacingQibla]: saat true, jarum & cincin berubah ke warna Teal (secondary)
///   sebagai umpan balik "sudah tepat".
class CompassDial extends StatelessWidget {
  const CompassDial({
    super.key,
    required this.heading,
    required this.relativeAngle,
    required this.isFacingQibla,
    this.size = 280,
  });

  final double heading;
  final double relativeAngle;
  final bool isFacingQibla;
  final double size;

  @override
  Widget build(BuildContext context) {
    final accent = isFacingQibla ? AppColors.secondary : AppColors.primary;

    return Semantics(
      label: isFacingQibla
          ? 'Kompas kiblat: Anda menghadap kiblat'
          : 'Kompas kiblat: putar ${relativeAngle.round()} derajat '
                '${relativeAngle > 180 ? 'ke kiri' : 'ke kanan'} menuju kiblat',
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Cincin luar + mata angin (berputar mengikuti -heading).
            Transform.rotate(
              angle: -heading * math.pi / 180.0,
              child: CustomPaint(
                size: Size.square(size),
                painter: _DialPainter(),
              ),
            ),
            // Jarum Ka'bah (menunjuk arah kiblat relatif).
            Transform.rotate(
              angle: relativeAngle * math.pi / 180.0,
              child: _QiblaNeedle(size: size, color: accent),
            ),
            // Pusat.
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.outline,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QiblaNeedle extends StatelessWidget {
  const _QiblaNeedle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: size * 0.06),
          // Ikon Ka'bah dalam kotak bordir tegas.
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color,
              border: AppShapes.hardBorder,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.mosque, size: 26, color: AppColors.onPrimary),
          ),
          // Batang jarum.
          Container(
            width: 6,
            height: size * 0.30,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.outline,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menggambar cincin kompas, tanda derajat, dan huruf mata angin.
class _DialPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.outline;
    canvas.drawCircle(center, radius - 2, ring);
    canvas.drawCircle(center, radius - 22, ring);

    final tick = Paint()
      ..color = AppColors.outline
      ..strokeWidth = 2;
    for (var deg = 0; deg < 360; deg += 15) {
      final major = deg % 45 == 0;
      final rad = (deg - 90) * math.pi / 180.0;
      final outer = radius - 4;
      final inner = radius - (major ? 20 : 12);
      final p1 = center + Offset(math.cos(rad) * outer, math.sin(rad) * outer);
      final p2 = center + Offset(math.cos(rad) * inner, math.sin(rad) * inner);
      canvas.drawLine(p1, p2, tick..strokeWidth = major ? 3 : 1.5);
    }

    // Huruf mata angin (U/T/S/B).
    const labels = {0: 'U', 90: 'T', 180: 'S', 270: 'B'};
    labels.forEach((deg, label) {
      final rad = (deg - 90) * math.pi / 180.0;
      final r = radius - 38;
      final offset = center + Offset(math.cos(rad) * r, math.sin(rad) * r);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: AppTypography.textTheme.titleMedium!.copyWith(
            color: deg == 0 ? AppColors.primary : AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
    });
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) => false;
}
