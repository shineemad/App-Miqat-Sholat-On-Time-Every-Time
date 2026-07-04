import 'quran_bookmark_repository.dart';
import 'quran_repository.dart';
import 'models/quran_models.dart';

/// Isi layar baca satu surah (metadata + ayat + status bookmark).
class SurahReading {
  const SurahReading({
    required this.surah,
    required this.verses,
    required this.bookmarkedAyahs,
  });

  final Surah surah;
  final List<Ayah> verses;

  /// Nomor ayat yang di-bookmark pada surah ini.
  final Set<int> bookmarkedAyahs;

  bool isBookmarked(int ayah) => bookmarkedAyahs.contains(ayah);
}

/// Controller fitur Al-Quran: menyatukan data ([QuranRepository]) dan
/// bookmark/progress ([QuranBookmarkRepository]).
class QuranController {
  QuranController({
    required QuranRepository repository,
    required QuranBookmarkRepository bookmarks,
  })  : _repo = repository,
        _bookmarks = bookmarks;

  final QuranRepository _repo;
  final QuranBookmarkRepository _bookmarks;

  Future<List<Surah>> loadSurahs() => _repo.getSurahs();

  Future<QuranSearchResult> search(String query) => _repo.search(query);

  /// Posisi bacaan terakhir (untuk kartu "Lanjutkan membaca").
  ReadingPosition? lastRead() => _bookmarks.getLastRead();

  /// Muat isi surah lengkap dengan status bookmark tiap ayat.
  Future<SurahReading> loadSurah(int number) async {
    final surah = await _repo.getSurah(number);
    if (surah == null) {
      throw ArgumentError('Surah $number tidak ditemukan');
    }
    final verses = await _repo.getVerses(number);
    final bookmarked = _bookmarks
        .getBookmarks()
        .where((p) => p.surah == number)
        .map((p) => p.ayah)
        .toSet();
    return SurahReading(
      surah: surah,
      verses: verses,
      bookmarkedAyahs: bookmarked,
    );
  }

  /// Toggle bookmark satu ayat; mengembalikan status akhir.
  Future<bool> toggleBookmark(int surah, int ayah) =>
      _bookmarks.toggleBookmark(surah, ayah);

  /// Simpan progress bacaan terakhir.
  Future<void> markRead(int surah, int ayah) =>
      _bookmarks.setLastRead(surah, ayah);
}
