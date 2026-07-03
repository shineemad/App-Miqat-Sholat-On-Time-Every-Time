/// Representasi tanggal dalam kalender Hijriah.
class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate({
    required this.year,
    required this.month,
    required this.day,
  });

  static const _monthNames = [
    'Muharram',
    'Safar',
    "Rabi'ul Awwal",
    "Rabi'ul Akhir",
    'Jumadal Ula',
    'Jumadal Akhirah',
    'Rajab',
    "Sya'ban",
    'Ramadhan',
    'Syawwal',
    "Dzulqa'dah",
    'Dzulhijjah',
  ];

  /// Nama bulan Hijriah (bahasa Arab Latin).
  String get monthName => _monthNames[month - 1];

  /// Format lengkap: "3 Muharram 1448 H"
  String get fullDisplay => '$day $monthName $year H';

  /// Format singkat: "3 Muh 1448"
  String get shortDisplay => '$day ${monthName.substring(0, 3)} $year';

  @override
  String toString() => fullDisplay;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HijriDate &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode => Object.hash(year, month, day);
}
