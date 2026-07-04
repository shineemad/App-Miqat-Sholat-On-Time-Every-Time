import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_card.dart';
import '../models/quran_models.dart';

/// Baris satu surah pada daftar (nomor, nama latin/arab, arti, jumlah ayat).
class SurahTile extends StatelessWidget {
  const SurahTile({super.key, required this.surah, this.onTap});

  final Surah surah;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // Badge nomor surah (belah ketupat gaya brutalist).
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.tertiary,
              border: Border.all(color: AppColors.outline, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${surah.number}',
              style: AppTypography.textTheme.labelLarge!
                  .copyWith(color: AppColors.onTertiary, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(surah.nameLatin,
                    style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '${surah.meaning} · ${surah.ayahCount} ayat · ${surah.revelation}',
                  style: AppTypography.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            surah.nameArabic,
            style: AppTypography.textTheme.titleLarge!.copyWith(
              fontFamily: AppTypography.bodyFamily,
              fontWeight: FontWeight.w600,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}
