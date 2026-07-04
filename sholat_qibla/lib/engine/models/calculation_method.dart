/// Metode kalkulasi waktu sholat beserta parameter sudutnya.
///
/// Sudut fajr/isha dalam derajat di bawah horizon. Jika [ishaIntervalMinutes]
/// bernilai > 0, waktu Isha dihitung sebagai interval menit setelah Maghrib
/// (dipakai metode Umm al-Qura / Makkah).
enum CalculationMethod {
  /// Kementerian Agama Republik Indonesia.
  kemenag(fajrAngle: 20.0, ishaAngle: 18.0, label: 'Kemenag RI'),

  /// Muslim World League.
  mwl(fajrAngle: 18.0, ishaAngle: 17.0, label: 'Muslim World League'),

  /// Islamic Society of North America.
  isna(fajrAngle: 15.0, ishaAngle: 15.0, label: 'ISNA'),

  /// Egyptian General Authority of Survey.
  egypt(fajrAngle: 19.5, ishaAngle: 17.5, label: 'Egyptian Authority'),

  /// Umm al-Qura University, Makkah — Isha = 90 menit setelah Maghrib.
  makkah(
    fajrAngle: 18.5,
    ishaAngle: 0.0,
    ishaIntervalMinutes: 90,
    label: 'Umm al-Qura (Makkah)',
  ),

  /// University of Islamic Sciences, Karachi.
  karachi(fajrAngle: 18.0, ishaAngle: 18.0, label: 'Karachi');

  const CalculationMethod({
    required this.fajrAngle,
    required this.ishaAngle,
    required this.label,
    this.ishaIntervalMinutes = 0,
  });

  /// Sudut matahari di bawah horizon untuk Subuh (derajat).
  final double fajrAngle;

  /// Sudut matahari di bawah horizon untuk Isya (derajat).
  final double ishaAngle;

  /// Interval menit setelah Maghrib (0 = pakai [ishaAngle]).
  final int ishaIntervalMinutes;

  /// Nama tampilan metode.
  final String label;

  static CalculationMethod fromName(String name) =>
      CalculationMethod.values.firstWhere(
        (m) => m.name == name,
        orElse: () => CalculationMethod.kemenag,
      );
}
