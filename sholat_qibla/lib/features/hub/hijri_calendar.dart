/// Konversi kalender Gregorian (Masehi) <-> Hijriah (Umm al-Qura tabular,
/// varian aritmetika 'kabisat' dengan epoch 1 Muharram 1 H = 16 Juli 622 M
/// pada penanggalan Julian proleptik).
///
/// Akurasi tabular: umumnya ±1 hari dari rukyat resmi Kemenag. Cocok untuk
/// menampilkan tanggal Hijriah perkiraan (offline, tanpa server).
class HijriDate {
  const HijriDate({required this.year, required this.month, required this.day});

  final int year;
  final int month;
  final int day;

  static const List<String> monthNamesId = [
    'Muharram',
    'Safar',
    "Rabiul Awal",
    'Rabiul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    "Sya'ban",
    'Ramadhan',
    'Syawal',
    "Zulkaidah",
    'Zulhijjah',
  ];

  String get monthName => monthNamesId[month - 1];

  /// Format Indonesia: "10 Ramadhan 1447 H".
  String formatId() => '$day $monthName $year H';

  @override
  bool operator ==(Object other) =>
      other is HijriDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => 'HijriDate($year-$month-$day)';
}

/// Kalkulator konversi kalender Hijriah <-> Masehi (algoritma tabular).
abstract final class HijriCalendar {
  /// Julian Day Number dari tanggal Gregorian (proleptik).
  static int _gregorianToJdn(int year, int month, int day) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;
    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  /// Tanggal Gregorian dari Julian Day Number.
  static DateTime _jdnToGregorian(int jdn) {
    final a = jdn + 32044;
    final b = ((4 * a + 3) / 146097).floor();
    final c = a - ((146097 * b) / 4).floor();
    final d = ((4 * c + 3) / 1461).floor();
    final e = c - ((1461 * d) / 4).floor();
    final m = ((5 * e + 2) / 153).floor();
    final day = e - ((153 * m + 2) / 5).floor() + 1;
    final month = m + 3 - 12 * (m / 10).floor();
    final year = 100 * b + d - 4800 + (m / 10).floor();
    return DateTime(year, month, day);
  }

  // Epoch Islam: 1 Muharram 1 H = JDN 1948440 (16 Juli 622 M, Julian).
  static const int _islamicEpoch = 1948440;

  /// Konversi tanggal Masehi -> Hijriah.
  static HijriDate fromGregorian(DateTime date) {
    final jdn = _gregorianToJdn(date.year, date.month, date.day);
    final days = jdn - _islamicEpoch;
    // 30 tahun = 10631 hari dalam siklus tabular.
    final cycle = (days / 10631).floor();
    var remainder = days - cycle * 10631;

    var year = 30 * cycle + 1;
    // Kurangi tahun demi tahun (354 hari tahun biasa, 355 tahun kabisat).
    while (remainder >= _daysInYear(year)) {
      remainder -= _daysInYear(year);
      year++;
    }

    var month = 1;
    while (month < 12 && remainder >= _daysInMonth(year, month)) {
      remainder -= _daysInMonth(year, month);
      month++;
    }

    return HijriDate(year: year, month: month, day: remainder + 1);
  }

  /// Konversi tanggal Hijriah -> Masehi.
  static DateTime toGregorian(HijriDate hijri) {
    var days = 0;
    for (var y = 1; y < hijri.year; y++) {
      days += _daysInYear(y);
    }
    for (var m = 1; m < hijri.month; m++) {
      days += _daysInMonth(hijri.year, m);
    }
    days += hijri.day - 1;
    return _jdnToGregorian(_islamicEpoch + days);
  }

  /// Tahun kabisat Hijriah pada siklus 30 tahun (11 tahun kabisat).
  static bool isLeapYear(int year) {
    final y = ((year - 1) % 30) + 1;
    const leapYears = {2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29};
    return leapYears.contains(y);
  }

  /// Jumlah hari dalam bulan Hijriah: ganjil = 30, genap = 29,
  /// bulan 12 = 30 pada tahun kabisat.
  static int _daysInMonth(int year, int month) {
    if (month == 12 && isLeapYear(year)) return 30;
    return month.isOdd ? 30 : 29;
  }

  static int _daysInYear(int year) => isLeapYear(year) ? 355 : 354;
}
