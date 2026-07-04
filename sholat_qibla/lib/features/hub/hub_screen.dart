import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_card.dart';
import 'hub_feature_registry.dart';

/// Layar Hub (§3.5): grid fitur tambahan modular yang dirender dari
/// [HubFeatureRegistry]. Fitur tersedia dapat dibuka; fitur stub ditandai
/// "Segera Hadir".
class HubScreen extends StatelessWidget {
  const HubScreen({super.key, required this.onOpenFeature});

  /// Dipanggil saat fitur yang tersedia diketuk.
  final void Function(HubFeature feature) onOpenFeature;

  @override
  Widget build(BuildContext context) {
    final available = HubFeatureRegistry.available;
    final comingSoon = HubFeatureRegistry.comingSoon;

    return Scaffold(
      appBar: AppBar(title: const Text('Hub')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Fitur', style: AppTypography.textTheme.titleSmall),
            const SizedBox(height: 12),
            _Grid(
              features: available,
              onTap: onOpenFeature,
            ),
            const SizedBox(height: 24),
            Text('Segera Hadir', style: AppTypography.textTheme.titleSmall),
            const SizedBox(height: 12),
            _Grid(
              features: comingSoon,
              onTap: (f) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${f.title} — segera hadir')),
              ),
              dimmed: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.features,
    required this.onTap,
    this.dimmed = false,
  });

  final List<HubFeature> features;
  final void Function(HubFeature) onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final feature in features)
          _FeatureCard(
            feature: feature,
            dimmed: dimmed,
            onTap: () => onTap(feature),
          ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.feature,
    required this.onTap,
    required this.dimmed,
  });

  final HubFeature feature;
  final VoidCallback onTap;
  final bool dimmed;

  static const _icons = {
    'tasbih': Icons.touch_app,
    'quran': Icons.menu_book,
    'hijri': Icons.calendar_month,
    'mosque_finder': Icons.mosque,
    'ramadhan_mode': Icons.brightness_3,
  };

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: dimmed ? 0.6 : 1,
      child: NeoCard(
        onTap: onTap,
        highlighted: !dimmed,
        backgroundColor: dimmed
            ? AppColors.surfaceContainerHigh
            : AppColors.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: dimmed ? AppColors.surfaceContainerHighest : AppColors.secondary,
                border: Border.all(color: AppColors.outline, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _icons[feature.id] ?? Icons.widgets,
                size: 24,
                color: dimmed ? AppColors.onSurfaceVariant : AppColors.onSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Text(feature.title, style: AppTypography.textTheme.titleMedium),
            const SizedBox(height: 2),
            Text(
              feature.description,
              style: AppTypography.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
