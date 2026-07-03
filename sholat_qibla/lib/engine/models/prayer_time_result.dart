/// Hasil kalkulasi waktu sholat untuk satu hari.
///
/// Semua waktu dalam [DateTime] lokal (sudah termasuk timezone offset).
/// Nilai null berarti matahari tidak mencapai ketinggian tersebut
/// (fenomena lintang tinggi — tidak relevan di Indonesia).
class PrayerTimeResult {
  final DateTime date;
  final DateTime subuh;
  final DateTime syuruk;
  final DateTime dzuhur;
  final DateTime ashar;
  final DateTime maghrib;
  final DateTime isya;

  const PrayerTimeResult({
    required this.date,
    required this.subuh,
    required this.syuruk,
    required this.dzuhur,
    required this.ashar,
    required this.maghrib,
    required this.isya,
  });

  /// Daftar waktu sholat (5 waktu fardu, tanpa Syuruk).
  List<({String name, DateTime time})> get prayers => [
        (name: 'Subuh', time: subuh),
        (name: 'Dzuhur', time: dzuhur),
        (name: 'Ashar', time: ashar),
        (name: 'Maghrib', time: maghrib),
        (name: 'Isya', time: isya),
      ];

  /// Sholat berikutnya berdasarkan waktu sekarang.
  ///
  /// Mengembalikan null jika semua sholat hari ini sudah lewat
  /// (akan diisi dengan sholat Subuh keesokan harinya dari caller).
  ({String name, DateTime time})? nextPrayer(DateTime now) {
    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) return prayer;
    }
    return null;
  }

  /// Sisa waktu menuju [nextPrayer]. Null jika tidak ada lagi sholat hari ini.
  Duration? countdown(DateTime now) {
    final next = nextPrayer(now);
    if (next == null) return null;
    return next.time.difference(now);
  }

  @override
  String toString() =>
      'PrayerTimeResult(${date.year}-${date.month}-${date.day}, '
      'Subuh=${_fmt(subuh)}, Dzuhur=${_fmt(dzuhur)}, '
      'Ashar=${_fmt(ashar)}, Maghrib=${_fmt(maghrib)}, Isya=${_fmt(isya)})';

  static String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
