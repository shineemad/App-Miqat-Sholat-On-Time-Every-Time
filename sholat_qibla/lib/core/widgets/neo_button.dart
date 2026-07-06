import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Tombol primer Neo-Brutalist (§8.5 Button).
///
/// Base hitam pekat + teks putih, radius penuh, tinggi ≥ 44px.
/// Interaksi taktil: saat ditekan bergeser 2px & shadow hilang.
class NeoButton extends StatefulWidget {
  const NeoButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.expanded = false,
    this.withShadow = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  /// Warna latar; default [AppColors.outline] (mengikuti tema aktif).
  final Color? backgroundColor;

  /// Warna teks/ikon; default [AppColors.onPrimary] (mengikuti tema aktif).
  final Color? foregroundColor;

  /// Melebar memenuhi lebar induk.
  final bool expanded;

  /// Tampilkan hard shadow (hilang saat ditekan).
  final bool withShadow;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (!_enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final offset = _pressed ? 2.0 : 0.0;
    final showShadow = widget.withShadow && !_pressed && _enabled;
    final background = widget.backgroundColor ?? AppColors.outline;
    final foreground = widget.foregroundColor ?? AppColors.onPrimary;

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: Opacity(
        opacity: _enabled ? 1 : 0.5,
        child: GestureDetector(
          onTapDown: (_) => _setPressed(true),
          onTapUp: (_) => _setPressed(false),
          onTapCancel: () => _setPressed(false),
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(offset, offset, 0),
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            width: widget.expanded ? double.infinity : null,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: background,
              border: AppShapes.hardBorder,
              borderRadius: BorderRadius.circular(100),
              boxShadow: showShadow ? AppShapes.hardShadow : AppShapes.noShadow,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: 18, color: foreground),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: AppTypography.textTheme.labelLarge!.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
