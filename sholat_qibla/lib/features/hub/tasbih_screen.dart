import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_button.dart';
import '../../core/widgets/neo_card.dart';
import 'tasbih_counter.dart';

/// Layar Tasbih Digital: penghitung dzikir dengan target & putaran,
/// sesi tersimpan otomatis (offline).
class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key, required this.counter});

  final TasbihCounter counter;

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  late TasbihState _state = widget.counter.load();

  static const _targets = [33, 99, 100];

  Future<void> _increment() async {
    final next = await widget.counter.increment();
    setState(() => _state = next);
  }

  Future<void> _decrement() async {
    final next = await widget.counter.decrement();
    setState(() => _state = next);
  }

  Future<void> _reset() async {
    final next = await widget.counter.reset();
    setState(() => _state = next);
  }

  Future<void> _setTarget(int target) async {
    final next = await widget.counter.setTarget(target);
    setState(() => _state = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasbih Digital')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Pemilih target.
              Row(
                children: [
                  Text('Target', style: AppTypography.textTheme.titleSmall),
                  const SizedBox(width: 12),
                  for (final t in _targets) ...[
                    _TargetChip(
                      value: t,
                      selected: _state.target == t,
                      onTap: () => _setTarget(t),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Info putaran.
              NeoCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(label: 'Putaran', value: '${_state.rounds}'),
                    _Stat(
                        label: 'Target',
                        value: '${_state.count % _state.target}/${_state.target}'),
                  ],
                ),
              ),
              const Spacer(),
              // Penghitung besar (tap untuk menambah).
              GestureDetector(
                onTap: _increment,
                child: NeoCard(
                  active: true,
                  highlighted: true,
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Text(
                        '${_state.count}',
                        style: AppTypography.textTheme.displayLarge!
                            .copyWith(color: AppColors.onPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ketuk untuk berdzikir',
                        style: AppTypography.textTheme.bodyLarge!
                            .copyWith(color: AppColors.onPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: NeoButton(
                      label: 'Kurangi',
                      icon: Icons.remove,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      foregroundColor: AppColors.onSurface,
                      expanded: true,
                      onPressed: _state.count == 0 ? null : _decrement,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoButton(
                      label: 'Reset',
                      icon: Icons.refresh,
                      backgroundColor: AppColors.primary,
                      expanded: true,
                      onPressed: _state.count == 0 ? null : _reset,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  const _TargetChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceContainerLowest,
          border: Border.all(color: AppColors.outline, width: 2),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '$value',
          style: AppTypography.textTheme.labelLarge!.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.textTheme.headlineSmall),
        Text(label, style: AppTypography.textTheme.bodySmall),
      ],
    );
  }
}
