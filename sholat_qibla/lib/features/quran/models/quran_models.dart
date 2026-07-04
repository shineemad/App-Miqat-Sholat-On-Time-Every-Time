/// Metadata satu surah.
class Surah {
  const Surah({
    required this.number,
    required this.nameLatin,
    required this.nameArabic,
    required this.meaning,
    required this.ayahCount,
    required this.revelation,
  });

  final int number;
  final String nameLatin;
  final String nameArabic;

  /// Arti nama surah dalam bahasa Indonesia.
  final String meaning;
  final int ayahCount;

  /// "Makkiyah" atau "Madaniyah".
  final String revelation;

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
        number: json['number'] as int,
        nameLatin: json['nameLatin'] as String,
        nameArabic: json['nameArabic'] as String,
        meaning: json['meaning'] as String? ?? '',
        ayahCount: json['ayahCount'] as int,
        revelation: json['revelation'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) => other is Surah && other.number == number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Surah($number, $nameLatin)';
}

/// Satu ayat: teks Arab, transliterasi latin, dan terjemahan Indonesia.
class Ayah {
  const Ayah({
    required this.surah,
    required this.number,
    required this.juz,
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });

  final int surah;
  final int number;
  final int juz;
  final String arabic;
  final String transliteration;
  final String translation;

  /// Kunci unik "surah:ayah", mis. "1:5".
  String get key => '$surah:$number';

  factory Ayah.fromJson(Map<String, dynamic> json) => Ayah(
        surah: json['surah'] as int,
        number: json['ayah'] as int,
        juz: json['juz'] as int? ?? 0,
        arabic: json['arabic'] as String,
        transliteration: json['transliteration'] as String? ?? '',
        translation: json['translation'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) => other is Ayah && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// Penanda awal juz: juz ke-n dimulai pada surah:ayah tertentu.
class JuzMarker {
  const JuzMarker({required this.juz, required this.surah, required this.ayah});

  final int juz;
  final int surah;
  final int ayah;

  factory JuzMarker.fromJson(Map<String, dynamic> json) => JuzMarker(
        juz: json['juz'] as int,
        surah: json['surah'] as int,
        ayah: json['ayah'] as int,
      );
}
