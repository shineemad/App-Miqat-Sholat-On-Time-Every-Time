import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Toggle Neo-Brutalist (§8.5 Toggle).
///
/// 52×32, border hitam 3px, thumb hitam bulat. `on` → track Coral,
/// `off` → track putih. Target sentuh diperluas ke ≥ 44px.
class NeoToggle extends StatelessWidget {
  const NeoToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  static const double _trackWidth = 52;
  static const double _trackHeight = 32;
  static const double _thumbSize = 20;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;

    return Semantics(
      label: semanticLabel,
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Opacity(
              opacity: enabled ? 1 : 0.5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                curve: Curves.easeOut,
                width: _trackWidth,
                height: _trackHeight,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: value ? AppColors.primary : AppColors.onPrimary,
                  border: AppShapes.hardBorder,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  alignment:
                      value ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: _thumbSize,
                    height: _thumbSize,
                    decoration: const BoxDecoration(
                      color: AppColors.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
