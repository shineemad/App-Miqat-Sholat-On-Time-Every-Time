import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Satu item pada [NeoBottomNav].
class NeoNavItem {
  const NeoNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

/// Bottom navigation bar Neo-Brutalist (§8.7 Navigation).
///
/// Ikon kontras tinggi + label jelas; tab aktif ditandai lingkaran coral
/// khas. Border atas hitam tegas memisahkan dari konten.
class NeoBottomNav extends StatelessWidget {
  const NeoBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NeoNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: AppColors.outline,
            width: AppShapes.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NeoNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeOut,
            width: 44,
            height: 30,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.transparent,
              border: selected
                  ? Border.all(color: AppColors.outline, width: 2)
                  : null,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: selected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.label,
            style: AppTypography.textTheme.labelSmall!.copyWith(
              color: selected ? AppColors.onSurface : AppColors.onSurfaceVariant,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
