import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'models/quran_models.dart';

/// Repository data Al-Quran offline (asset JSON).
///
/// Menyediakan: metadata 114 surah, indeks 30 juz, teks ayat (Arab,
/// transliterasi, terjemahan), pencarian ayat, dan navigasi surah/juz.
///
/// Catatan: file asset berisi sampel ayat; struktur & parser sudah final
/// sehingga dataset penuh tinggal menggantikan `assets/data/quran.json`.
class QuranRepository {
  QuranRepository({AssetBundle? bundle, String? assetPath})
      : _bundle = bundle ?? rootBundle,
        _assetPath = assetPath ?? defaultAssetPath;

  static const String defaultAssetPath = 'assets/data/quran.json';

  final AssetBundle _bundle;
  final String _assetPath;

  List<Surah>? _surahs;
  List<JuzMarker>? _juzIndex;
  Map<int, List<Ayah>>? _versesBySurah;

  Future<void> _ensureLoaded() async {
    if (_surahs != null) return;
    final raw = await _bundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;

    _surahs = (json['surahs'] as List)
        .cast<Map<String, dynamic>>()
        .map(Surah.fromJson)
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    _juzIndex = (json['juzIndex'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(JuzMarker.fromJson)
        .toList()
      ..sort((a, b) => a.juz.compareTo(b.juz));

    final verses = (json['verses'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map(Ayah.fromJson);
    final map = <int, List<Ayah>>{};
    for (final ayah in verses) {
      map.putIfAbsent(ayah.surah, () => []).add(ayah);
    }
    for (final list in map.values) {
      list.sort((a, b) => a.number.compareTo(b.number));
    }
    _versesBySurah = map;
  }

  /// Seluruh metadata surah (114).
  Future<List<Surah>> getSurahs() async {
    await _ensureLoaded();
    return List.unmodifiable(_surahs!);
  }

  /// Metadata satu surah, atau `null` bila [number] di luar 1-114.
  Future<Surah?> getSurah(int number) async {
    await _ensureLoaded();
    if (number < 1 || number > _surahs!.length) return null;
    return _surahs![number - 1];
  }

  /// Ayat-ayat sebuah surah. Kosong bila teks belum tersedia di dataset.
  Future<List<Ayah>> getVerses(int surahNumber) async {
    await _ensureLoaded();
    return List.unmodifiable(_versesBySurah![surahNumber] ?? const <Ayah>[]);
  }

  /// Satu ayat spesifik, atau `null` bila tidak tersedia.
  Future<Ayah?> getAyah(int surahNumber, int ayahNumber) async {
    final verses = await getVerses(surahNumber);
    for (final ayah in verses) {
      if (ayah.number == ayahNumber) return ayah;
    }
    return null;
  }

  /// Indeks 30 juz (juz -> surah:ayah awal).
  Future<List<JuzMarker>> getJuzIndex() async {
    await _ensureLoaded();
    return List.unmodifiable(_juzIndex!);
  }

  /// Penanda awal [juz] (1-30), atau `null` bila tidak valid.
  Future<JuzMarker?> getJuzStart(int juz) async {
    await _ensureLoaded();
    if (juz < 1 || juz > _juzIndex!.length) return null;
    return _juzIndex![juz - 1];
  }

  /// Nomor juz tempat surah:ayah berada.
  Future<int> juzOf(int surahNumber, int ayahNumber) async {
    await _ensureLoaded();
    var result = 1;
    for (final marker in _juzIndex!) {
      final started = surahNumber > marker.surah ||
          (surahNumber == marker.surah && ayahNumber >= marker.ayah);
      if (started) result = marker.juz;
    }
    return result;
  }

  /// Pencarian ayat pada terjemahan & transliterasi (case-insensitive),
  /// juga mencocokkan nama surah.
  Future<QuranSearchResult> search(String query) async {
    await _ensureLoaded();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      return const QuranSearchResult(surahs: [], verses: []);
    }

    final surahMatches = _surahs!
        .where((s) =>
            s.nameLatin.toLowerCase().contains(q) ||
            s.meaning.toLowerCase().contains(q))
        .toList();

    final verseMatches = <Ayah>[
      for (final verses in _versesBySurah!.values)
        ...verses.where((a) =>
            a.translation.toLowerCase().contains(q) ||
            a.transliteration.toLowerCase().contains(q)),
    ]..sort((a, b) => a.surah != b.surah
        ? a.surah.compareTo(b.surah)
        : a.number.compareTo(b.number));

    return QuranSearchResult(surahs: surahMatches, verses: verseMatches);
  }

  void clearCache() {
    _surahs = null;
    _juzIndex = null;
    _versesBySurah = null;
  }
}

/// Hasil pencarian: surah yang cocok nama, dan ayat yang cocok teks.
class QuranSearchResult {
  const QuranSearchResult({required this.surahs, required this.verses});

  final List<Surah> surahs;
  final List<Ayah> verses;

  bool get isEmpty => surahs.isEmpty && verses.isEmpty;
}
