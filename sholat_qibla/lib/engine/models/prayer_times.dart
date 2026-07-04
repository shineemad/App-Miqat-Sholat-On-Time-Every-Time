/// Nama-nama waktu sholat (plus sunrise sebagai penanda akhir Subuh).
enum Prayer { fajr, sunrise, dhuhr, asr, maghrib, isha }

/// Hasil perhitungan waktu sholat untuk satu hari pada satu lokasi.
class PrayerTimes {
  const PrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  /// Tanggal (komponen tahun-bulan-hari) perhitungan, dalam waktu lokal.
  final DateTime date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  DateTime timeFor(Prayer prayer) => switch (prayer) {
        Prayer.fajr => fajr,
        Prayer.sunrise => sunrise,
        Prayer.dhuhr => dhuhr,
        Prayer.asr => asr,
        Prayer.maghrib => maghrib,
        Prayer.isha => isha,
      };

  /// Sholat berikutnya setelah [time], atau `null` jika semua sudah lewat.
  Prayer? nextPrayer(DateTime time) {
    for (final prayer in Prayer.values) {
      if (prayer == Prayer.sunrise) continue;
      if (time.isBefore(timeFor(prayer))) return prayer;
    }
    return null;
  }

  /// Sholat yang sedang berlangsung pada [time], atau `null` sebelum Subuh.
  Prayer? currentPrayer(DateTime time) {
    Prayer? current;
    for (final prayer in Prayer.values) {
      if (prayer == Prayer.sunrise) continue;
      if (!time.isBefore(timeFor(prayer))) current = prayer;
    }
    return current;
  }

  /// Mengembalikan salinan dengan offset menit per waktu sholat.
  PrayerTimes withOffsets(Map<Prayer, int> offsets) => PrayerTimes(
        date: date,
        fajr: fajr.add(Duration(minutes: offsets[Prayer.fajr] ?? 0)),
        sunrise: sunrise.add(Duration(minutes: offsets[Prayer.sunrise] ?? 0)),
        dhuhr: dhuhr.add(Duration(minutes: offsets[Prayer.dhuhr] ?? 0)),
        asr: asr.add(Duration(minutes: offsets[Prayer.asr] ?? 0)),
        maghrib: maghrib.add(Duration(minutes: offsets[Prayer.maghrib] ?? 0)),
        isha: isha.add(Duration(minutes: offsets[Prayer.isha] ?? 0)),
      );

  @override
  String toString() =>
      'PrayerTimes(fajr: $fajr, sunrise: $sunrise, dhuhr: $dhuhr, '
      'asr: $asr, maghrib: $maghrib, isha: $isha)';
}
