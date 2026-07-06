import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Kartu Neo-Brutalist (§8.5 Card).
///
/// - `default`: putih, border hitam 3px, radius 20px, tanpa shadow.
/// - `active`: fill Coral + teks putih (set [active] = true).
/// - `highlighted`: hard shadow 4px (set [highlighted] = true).
class NeoCard extends StatelessWidget {
  const NeoCard({
    super.key,
    required this.child,
    this.active = false,
    this.highlighted = false,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.semanticLabel,
  });

  final Widget child;

  /// State aktif: fill Coral, teks putih.
  final bool active;

  /// Tambahkan hard shadow 4px.
  final bool highlighted;

  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Override warna latar (mis. varian Teal/Yellow). Diabaikan bila [active].
  final Color? backgroundColor;

  /// Label untuk screen reader (dipakai bila kartu dapat ditekan).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bg = active
        ? AppColors.primary
        : (backgroundColor ?? AppColors.surfaceContainerLowest);

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        border: AppShapes.hardBorder,
        borderRadius: AppShapes.card,
        boxShadow: highlighted ? AppShapes.hardShadow : AppShapes.noShadow,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: active ? AppColors.onPrimary : AppColors.onSurface,
        ),
        child: IconTheme.merge(
          data: IconThemeData(
            color: active ? AppColors.onPrimary : AppColors.onSurface,
          ),
          child: child,
        ),
      ),
    );

    if (onTap == null) return card;
    return Semantics(
      button: true,
      label: semanticLabel,
      selected: active,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      ),
    );
  }
}
