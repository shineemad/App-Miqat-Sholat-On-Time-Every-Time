import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../engine/models/prayer_times.dart';
import '../prayer_display.dart';

/// Baris satu waktu sholat pada daftar 5 waktu (Beranda).
///
/// Sholat yang sedang berlangsung disorot dengan state `active` (fill Coral)
/// dan hard shadow — sesuai spesifikasi "Prayer Time Card" (§8.7).
class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    super.key,
    required this.prayer,
    required this.time,
    this.isActive = false,
    this.isNext = false,
  });

  final Prayer prayer;
  final DateTime time;

  /// Sholat yang sedang berlangsung sekarang.
  final bool isActive;

  /// Sholat berikutnya (ditandai chip aksen bila tidak aktif).
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      active: isActive,
      highlighted: isActive,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            _iconFor(prayer),
            size: 22,
            color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              PrayerDisplay.label(prayer),
              style: AppTypography.textTheme.titleMedium!.copyWith(
                color: isActive ? AppColors.onPrimary : AppColors.onSurface,
              ),
            ),
          ),
          if (isNext && !isActive)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                border: Border.all(color: AppColors.outline, width: 2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                'Berikutnya',
                style: AppTypography.textTheme.labelSmall!.copyWith(
                  color: AppColors.onTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            PrayerDisplay.time(time),
            style: AppTypography.textTheme.titleLarge!.copyWith(
              fontFamily: AppTypography.headingFamily,
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.onPrimary : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(Prayer prayer) => switch (prayer) {
        Prayer.fajr => Icons.wb_twilight,
        Prayer.sunrise => Icons.wb_sunny_outlined,
        Prayer.dhuhr => Icons.light_mode,
        Prayer.asr => Icons.wb_cloudy_outlined,
        Prayer.maghrib => Icons.nightlight_round,
        Prayer.isha => Icons.dark_mode,
      };
}
