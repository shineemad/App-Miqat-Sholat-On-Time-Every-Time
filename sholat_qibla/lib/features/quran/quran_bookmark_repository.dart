import 'package:shared_preferences/shared_preferences.dart';

/// Posisi bacaan (surah:ayah).
class ReadingPosition {
  const ReadingPosition({required this.surah, required this.ayah});

  final int surah;
  final int ayah;

  String encode() => '$surah:$ayah';

  static ReadingPosition? decode(String? value) {
    if (value == null) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final s = int.tryParse(parts[0]);
    final a = int.tryParse(parts[1]);
    if (s == null || a == null) return null;
    return ReadingPosition(surah: s, ayah: a);
  }

  @override
  bool operator ==(Object other) =>
      other is ReadingPosition && other.surah == surah && other.ayah == ayah;

  @override
  int get hashCode => Object.hash(surah, ayah);

  @override
  String toString() => 'ReadingPosition($surah:$ayah)';
}

/// Penyimpanan bookmark ayat & progress membaca (lokal, offline).
class QuranBookmarkRepository {
  QuranBookmarkRepository(this._prefs);

  static const _kBookmarks = 'quran_bookmarks';
  static const _kLastRead = 'quran_last_read';

  final SharedPreferences _prefs;

  static Future<QuranBookmarkRepository> create(
          {SharedPreferences? prefs}) async =>
      QuranBookmarkRepository(prefs ?? await SharedPreferences.getInstance());

  // ------------------------------------------------------------------
  // Bookmark
  // ------------------------------------------------------------------

  List<ReadingPosition> getBookmarks() {
    final raw = _prefs.getStringList(_kBookmarks) ?? const [];
    return raw
        .map(ReadingPosition.decode)
        .whereType<ReadingPosition>()
        .toList();
  }

  bool isBookmarked(int surah, int ayah) {
    final target = ReadingPosition(surah: surah, ayah: ayah);
    return getBookmarks().contains(target);
  }

  Future<void> addBookmark(int surah, int ayah) async {
    final bookmarks = getBookmarks();
    final position = ReadingPosition(surah: surah, ayah: ayah);
    if (bookmarks.contains(position)) return;
    bookmarks.add(position);
    await _persist(bookmarks);
  }

  Future<void> removeBookmark(int surah, int ayah) async {
    final position = ReadingPosition(surah: surah, ayah: ayah);
    final bookmarks = getBookmarks()..remove(position);
    await _persist(bookmarks);
  }

  /// Menambah bila belum ada, menghapus bila sudah ada. Mengembalikan
  /// status akhir (true = kini ter-bookmark).
  Future<bool> toggleBookmark(int surah, int ayah) async {
    if (isBookmarked(surah, ayah)) {
      await removeBookmark(surah, ayah);
      return false;
    }
    await addBookmark(surah, ayah);
    return true;
  }

  Future<void> _persist(List<ReadingPosition> bookmarks) async {
    await _prefs.setStringList(
      _kBookmarks,
      bookmarks.map((b) => b.encode()).toList(),
    );
  }

  // ------------------------------------------------------------------
  // Progress membaca (last read)
  // ------------------------------------------------------------------

  ReadingPosition? getLastRead() =>
      ReadingPosition.decode(_prefs.getString(_kLastRead));

  Future<void> setLastRead(int surah, int ayah) => _prefs.setString(
      _kLastRead, ReadingPosition(surah: surah, ayah: ayah).encode());
}
