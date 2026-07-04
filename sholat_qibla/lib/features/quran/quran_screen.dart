import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/neo_card.dart';
import 'models/quran_models.dart';
import 'quran_controller.dart';
import 'quran_repository.dart';
import 'surah_screen.dart';
import 'widgets/surah_tile.dart';

/// Layar Al-Quran: daftar 114 surah, pencarian ayat/surah, dan kartu
/// "Lanjutkan membaca" berdasarkan progress terakhir.
class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key, required this.controller});

  final QuranController controller;

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  final _searchController = TextEditingController();
  List<Surah> _surahs = const [];
  QuranSearchResult? _searchResult;
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final surahs = await widget.controller.loadSurahs();
    if (!mounted) return;
    setState(() {
      _surahs = surahs;
      _loading = false;
    });
  }

  Future<void> _onSearch(String value) async {
    final query = value.trim();
    setState(() => _query = query);
    if (query.isEmpty) {
      setState(() => _searchResult = null);
      return;
    }
    final result = await widget.controller.search(query);
    if (!mounted) return;
    setState(() => _searchResult = result);
  }

  Future<void> _openSurah(int number, {int? scrollToAyah}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurahScreen(
          controller: widget.controller,
          surahNumber: number,
          scrollToAyah: scrollToAyah,
        ),
      ),
    );
    // Perbarui kartu "Lanjutkan membaca" setelah kembali.
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Al-Quran')),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  _SearchBar(
                    controller: _searchController,
                    onChanged: _onSearch,
                  ),
                  Expanded(
                    child: _query.isEmpty
                        ? _buildSurahList()
                        : _buildSearchResults(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSurahList() {
    final lastRead = widget.controller.lastRead();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (lastRead != null) ...[
          _ContinueReadingCard(
            position: lastRead,
            surahName: _surahName(lastRead.surah),
            onTap: () =>
                _openSurah(lastRead.surah, scrollToAyah: lastRead.ayah),
          ),
          const SizedBox(height: 12),
        ],
        for (final surah in _surahs) ...[
          SurahTile(surah: surah, onTap: () => _openSurah(surah.number)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildSearchResults() {
    final result = _searchResult;
    if (result == null || result.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Tidak ada hasil untuk "$_query"',
            style: AppTypography.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        if (result.surahs.isNotEmpty) ...[
          _SectionLabel('Surah (${result.surahs.length})'),
          for (final surah in result.surahs) ...[
            SurahTile(surah: surah, onTap: () => _openSurah(surah.number)),
            const SizedBox(height: 10),
          ],
        ],
        if (result.verses.isNotEmpty) ...[
          _SectionLabel('Ayat (${result.verses.length})'),
          for (final ayah in result.verses) ...[
            _VerseResultCard(
              ayah: ayah,
              surahName: _surahName(ayah.surah),
              onTap: () =>
                  _openSurah(ayah.surah, scrollToAyah: ayah.number),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }

  String _surahName(int number) {
    for (final s in _surahs) {
      if (s.number == number) return s.nameLatin;
    }
    return 'Surah $number';
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: NeoCard(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: AppColors.surfaceContainerLowest,
        child: Row(
          children: [
            const Icon(Icons.search, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Cari surah atau ayat…',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: const Icon(Icons.close, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(text, style: AppTypography.textTheme.titleSmall),
      );
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.position,
    required this.surahName,
    required this.onTap,
  });

  final dynamic position;
  final String surahName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      active: true,
      highlighted: true,
      onTap: onTap,
      child: Row(
        children: [
          const Icon(Icons.menu_book, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lanjutkan membaca',
                    style: AppTypography.textTheme.labelLarge!
                        .copyWith(color: AppColors.onPrimary)),
                const SizedBox(height: 2),
                Text('$surahName : ayat ${position.ayah}',
                    style: AppTypography.textTheme.titleMedium!
                        .copyWith(color: AppColors.onPrimary)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }
}

class _VerseResultCard extends StatelessWidget {
  const _VerseResultCard({
    required this.ayah,
    required this.surahName,
    required this.onTap,
  });

  final Ayah ayah;
  final String surahName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NeoCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$surahName : ${ayah.number}',
              style: AppTypography.textTheme.labelMedium!
                  .copyWith(color: AppColors.primary)),
          const SizedBox(height: 6),
          Text(ayah.translation, style: AppTypography.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
