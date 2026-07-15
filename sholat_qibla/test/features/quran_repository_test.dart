import 'package:flutter_test/flutter_test.dart';
import 'package:mu_qibla/features/quran/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuranRepository repo;
  setUp(() => repo = QuranRepository());

  group('QuranRepository - surah & juz', () {
    test('memuat 114 surah terurut', () async {
      final surahs = await repo.getSurahs();
      expect(surahs.length, 114);
      expect(surahs.first.number, 1);
      expect(surahs.first.nameLatin, 'Al-Fatihah');
      expect(surahs.last.number, 114);
      expect(surahs.last.nameLatin, 'An-Nas');
    });

    test('getSurah valid & di luar rentang', () async {
      expect((await repo.getSurah(2))!.ayahCount, 286);
      expect(await repo.getSurah(0), isNull);
      expect(await repo.getSurah(115), isNull);
    });

    test('indeks 30 juz tersedia', () async {
      final juz = await repo.getJuzIndex();
      expect(juz.length, 30);
      expect(juz.first.juz, 1);
      expect(juz.first.surah, 1);
      expect(juz.last.juz, 30);
      expect(juz.last.surah, 78);
    });

    test('getJuzStart & juzOf', () async {
      final start = await repo.getJuzStart(30);
      expect(start!.surah, 78);
      expect(await repo.juzOf(1, 1), 1);
      expect(await repo.juzOf(2, 142), 2);
      expect(await repo.juzOf(78, 1), 30);
      expect(await repo.juzOf(114, 6), 30);
    });
  });

  group('QuranRepository - ayat', () {
    test('parser teks Arab, transliterasi, terjemahan', () async {
      final verses = await repo.getVerses(1);
      expect(verses.length, 7);
      final basmalah = verses.first;
      expect(basmalah.arabic, contains('بِسْمِ'));
      expect(basmalah.transliteration, contains('Bismill'));
      expect(basmalah.translation, contains('Maha Pengasih'));
      expect(basmalah.key, '1:1');
      expect(basmalah.juz, 1);
    });

    test('getAyah spesifik', () async {
      final ayah = await repo.getAyah(112, 1);
      expect(ayah, isNotNull);
      expect(ayah!.transliteration, contains('Qul'));
      expect(await repo.getAyah(112, 99), isNull);
    });

    test('semua surah memiliki ayat sesuai jumlah metadata', () async {
      // Al-Baqarah 286, Qaf 45, An-Nas 6.
      expect((await repo.getVerses(2)).length, 286);
      expect((await repo.getVerses(50)).length, 45);
      expect((await repo.getVerses(114)).length, 6);
    });
  });

  group('QuranRepository - pencarian', () {
    test('cari terjemahan (case-insensitive)', () async {
      final result = await repo.search('MANUSIA');
      expect(result.isEmpty, isFalse);
      expect(result.verses.any((a) => a.surah == 114), isTrue);
    });

    test('cari nama surah', () async {
      final result = await repo.search('ikhlas');
      expect(result.surahs.any((s) => s.number == 112), isTrue);
    });

    test('cari transliterasi', () async {
      final result = await repo.search('qul');
      expect(result.verses.any((a) => a.surah == 112), isTrue);
    });

    test('query kosong => hasil kosong', () async {
      final result = await repo.search('  ');
      expect(result.isEmpty, isTrue);
    });
  });

  test('cache dipakai & bisa dibersihkan', () async {
    final a = await repo.getSurahs();
    final b = await repo.getSurahs();
    expect(identical(a, b), isFalse); // unmodifiable wrapper baru tiap panggil
    repo.clearCache();
    final c = await repo.getSurahs();
    expect(c.length, a.length);
  });
}
