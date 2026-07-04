import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_card.dart';
import 'models/quran_models.dart';
import 'quran_controller.dart';

/// Layar baca satu surah: teks Arab, transliterasi, terjemahan, dan
/// bookmark per ayat. Menyimpan progress "terakhir dibaca" saat dibuka.
class SurahScreen extends StatefulWidget {
  const SurahScreen({
    super.key,
    required this.controller,
    required this.surahNumber,
    this.scrollToAyah,
  });

  final QuranController controller;
  final int surahNumber;

  /// Ayat yang di-scroll otomatis saat masuk (dari "lanjut baca"/pencarian).
  final int? scrollToAyah;

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {
  SurahReading? _reading;
  bool _loading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reading = await widget.controller.loadSurah(widget.surahNumber);
      if (!mounted) return;
      setState(() {
        _reading = reading;
        _loading = false;
      });
      // Simpan progress: ayat tujuan, atau ayat pertama.
      final ayah = widget.scrollToAyah ??
          (reading.verses.isNotEmpty ? reading.verses.first.number : 1);
      await widget.controller.markRead(widget.surahNumber, ayah);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _toggleBookmark(int ayah) async {
    await widget.controller.toggleBookmark(widget.surahNumber, ayah);
    final reading = await widget.controller.loadSurah(widget.surahNumber);
    if (!mounted) return;
    setState(() => _reading = reading);
  }

  @override
  Widget build(BuildContext context) {
    final reading = _reading;
    return Scaffold(
      appBar: AppBar(
        title: Text(reading?.surah.nameLatin ?? 'Surah'),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_error != null || _reading == null) {
      return Center(
        child: Text('Gagal memuat surah',
            style: AppTypography.textTheme.titleMedium),
      );
    }

    final reading = _reading!;
    final verses = reading.verses;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SurahHeader(surah: reading.surah),
        const SizedBox(height: 16),
        if (verses.isEmpty)
          NeoCard(
            backgroundColor: AppColors.tertiaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 22),
                const SizedBox(height: 8),
                Text('Teks ayat belum tersedia',
                    style: AppTypography.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  'Data ayat untuk surah ini belum dimuat pada rilis ini. '
                  'Struktur bacaan sudah siap saat dataset penuh ditambahkan.',
                  style: AppTypography.textTheme.bodyMedium,
                ),
              ],
            ),
          )
        else
          for (final ayah in verses) ...[
            _AyahCard(
              ayah: ayah,
              bookmarked: reading.isBookmarked(ayah.number),
              onBookmark: () => _toggleBookmark(ayah.number),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      active: true,
      highlighted: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            surah.nameArabic,
            style: AppTypography.textTheme.displaySmall!.copyWith(
              color: AppColors.onPrimary,
              fontFamily: AppTypography.bodyFamily,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 6),
          Text(
            '${surah.nameLatin} · ${surah.meaning}',
            style: AppTypography.textTheme.titleMedium!
                .copyWith(color: AppColors.onPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            '${surah.revelation} · ${surah.ayahCount} ayat',
            style: AppTypography.textTheme.bodyMedium!
                .copyWith(color: AppColors.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _AyahCard extends StatelessWidget {
  const _AyahCard({
    required this.ayah,
    required this.bookmarked,
    required this.onBookmark,
  });

  final Ayah ayah;
  final bool bookmarked;
  final VoidCallback onBookmark;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      highlighted: bookmarked,
      backgroundColor: AppColors.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  border: Border.all(color: AppColors.outline, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${ayah.number}',
                    style: AppTypography.textTheme.labelMedium!.copyWith(
                        color: AppColors.onSecondary,
                        fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onBookmark,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: bookmarked
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Teks Arab (kanan-ke-kiri, besar).
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              ayah.arabic,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: AppTypography.textTheme.headlineSmall!.copyWith(
                fontFamily: AppTypography.bodyFamily,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            ayah.transliteration,
            style: AppTypography.textTheme.bodyMedium!.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(ayah.translation, style: AppTypography.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
