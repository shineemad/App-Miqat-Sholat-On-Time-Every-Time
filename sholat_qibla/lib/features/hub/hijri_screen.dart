import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_card.dart';
import 'hijri_calendar.dart';

/// Layar Kalender Hijriah: menampilkan tanggal Masehi & Hijriah hari ini,
/// serta konverter tanggal Masehi → Hijriah interaktif.
class HijriScreen extends StatefulWidget {
  const HijriScreen({super.key, this.clock});

  /// Sumber waktu (untuk test). Default [DateTime.now].
  final DateTime Function()? clock;

  @override
  State<HijriScreen> createState() => _HijriScreenState();
}

class _HijriScreenState extends State<HijriScreen> {
  late DateTime _selected = (widget.clock ?? DateTime.now)();

  static const _weekdays = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];
  static const _months = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli',
    'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  String _formatGregorian(DateTime d) =>
      '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    if (picked != null) setState(() => _selected = picked);
  }

  @override
  Widget build(BuildContext context) {
    final hijri = HijriCalendar.fromGregorian(_selected);

    return Scaffold(
      appBar: AppBar(title: const Text('Kalender Hijriah')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Kartu Hijriah besar.
            NeoCard(
              active: true,
              highlighted: true,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    '${hijri.day}',
                    style: AppTypography.textTheme.displayLarge!
                        .copyWith(color: AppColors.onPrimary),
                  ),
                  Text(
                    '${hijri.monthName} ${hijri.year} H',
                    style: AppTypography.textTheme.titleLarge!
                        .copyWith(color: AppColors.onPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tanggal Masehi terpilih + tombol ganti.
            NeoCard(
              onTap: _pickDate,
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tanggal Masehi',
                            style: AppTypography.textTheme.bodySmall),
                        const SizedBox(height: 2),
                        Text(_formatGregorian(_selected),
                            style: AppTypography.textTheme.titleMedium),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, size: 18),
                ],
              ),
            ),
            const SizedBox(height: 12),
            NeoCard(
              backgroundColor: AppColors.tertiaryContainer,
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Perhitungan tabular (Umm al-Qura). Bisa berbeda '
                      '±1 hari dari penetapan rukyat resmi.',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
