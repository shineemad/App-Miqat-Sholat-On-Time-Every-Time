import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../engine/models/prayer_times.dart';
import '../prayer_display.dart';

/// Kartu hero Beranda: sholat berikutnya + hitung mundur besar.
///
/// Menggunakan fill Coral (state aktif) untuk menarik mata langsung ke
/// informasi terpenting (§8.1 Unapologetic Hierarchy).
class NextPrayerHero extends StatelessWidget {
  const NextPrayerHero({
    super.key,
    required this.prayer,
    required this.time,
    required this.remaining,
  });

  /// Sholat berikutnya; `null` bila semua waktu hari ini sudah lewat.
  final Prayer? prayer;
  final DateTime? time;
  final Duration? remaining;

  @override
  Widget build(BuildContext context) {
    if (prayer == null || time == null || remaining == null) {
      return NeoCard(
        highlighted: true,
        padding: const EdgeInsets.all(24),
        backgroundColor: AppColors.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Alhamdulillah',
                style: AppTypography.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Semua waktu sholat hari ini telah usai',
                style: AppTypography.textTheme.bodyMedium),
          ],
        ),
      );
    }

    return NeoCard(
      active: true,
      highlighted: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, size: 18),
              const SizedBox(width: 6),
              Text(
                'Menuju ${PrayerDisplay.label(prayer!)}',
                style: AppTypography.textTheme.labelLarge!
                    .copyWith(color: AppColors.onPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            PrayerDisplay.countdown(remaining!),
            style: AppTypography.textTheme.displayMedium!.copyWith(
              color: AppColors.onPrimary,
              fontFeatures: const [], // angka tabular via Poppins bold
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'lagi · pukul ${PrayerDisplay.time(time!)}',
            style: AppTypography.textTheme.bodyLarge!
                .copyWith(color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }
}
