import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/features/quran/quran_bookmark_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<QuranBookmarkRepository> createRepo(
      [Map<String, Object> initial = const {}]) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return QuranBookmarkRepository(prefs);
  }

  group('ReadingPosition encode/decode', () {
    test('roundtrip', () {
      const pos = ReadingPosition(surah: 2, ayah: 255);
      expect(pos.encode(), '2:255');
      expect(ReadingPosition.decode('2:255'), pos);
    });

    test('decode input tidak valid => null', () {
      expect(ReadingPosition.decode(null), isNull);
      expect(ReadingPosition.decode('abc'), isNull);
      expect(ReadingPosition.decode('1:2:3'), isNull);
      expect(ReadingPosition.decode('x:y'), isNull);
    });
  });

  group('Bookmark', () {
    test('default kosong', () async {
      final repo = await createRepo();
      expect(repo.getBookmarks(), isEmpty);
      expect(repo.isBookmarked(1, 1), isFalse);
    });

    test('add & isBookmarked', () async {
      final repo = await createRepo();
      await repo.addBookmark(2, 255);
      expect(repo.isBookmarked(2, 255), isTrue);
      expect(repo.getBookmarks(), [const ReadingPosition(surah: 2, ayah: 255)]);
    });

    test('add duplikat tidak menggandakan', () async {
      final repo = await createRepo();
      await repo.addBookmark(1, 1);
      await repo.addBookmark(1, 1);
      expect(repo.getBookmarks().length, 1);
    });

    test('remove', () async {
      final repo = await createRepo();
      await repo.addBookmark(1, 1);
      await repo.removeBookmark(1, 1);
      expect(repo.isBookmarked(1, 1), isFalse);
    });

    test('toggle', () async {
      final repo = await createRepo();
      expect(await repo.toggleBookmark(36, 1), isTrue);
      expect(repo.isBookmarked(36, 1), isTrue);
      expect(await repo.toggleBookmark(36, 1), isFalse);
      expect(repo.isBookmarked(36, 1), isFalse);
    });

    test('persistensi antar instance', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await QuranBookmarkRepository(prefs).addBookmark(18, 10);
      final repo2 = QuranBookmarkRepository(prefs);
      expect(repo2.isBookmarked(18, 10), isTrue);
    });
  });

  group('Progress membaca', () {
    test('last read default null lalu tersimpan', () async {
      final repo = await createRepo();
      expect(repo.getLastRead(), isNull);
      await repo.setLastRead(67, 5);
      expect(repo.getLastRead(), const ReadingPosition(surah: 67, ayah: 5));
    });
  });
}
