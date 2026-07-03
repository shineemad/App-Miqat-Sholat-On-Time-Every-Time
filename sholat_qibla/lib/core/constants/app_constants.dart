/// Konstanta global aplikasi.

// ── Versi ─────────────────────────────────────────────────────────────────
const kAppVersion = '1.0.0';

// ── Prayer Engine — Kemenag Indonesia ────────────────────────────────────
const kKemenagFajrAngle = 20.0;
const kKemenagIshaAngle = 18.0;

/// Daftar metode perhitungan yang tersedia (nama tampilan → parameter sudut).
const kCalculationMethods = [
  (name: 'Kemenag', fajr: 20.0, isha: 18.0),
  (name: 'MWL',     fajr: 18.0, isha: 17.0),
  (name: 'ISNA',    fajr: 15.0, isha: 15.0),
  (name: 'Umm al-Qura', fajr: 18.0, isha: 0.0),
];

/// Kota default saat aplikasi pertama dibuka (Jakarta).
const kDefaultCityId = 'jakarta';

// ── Timezone offset (UTC+) ────────────────────────────────────────────────
/// Map nama timezone IANA ke offset UTC dalam jam.
const Map<String, int> kTimezoneOffsets = {
  'Asia/Jakarta':  7,   // WIB
  'Asia/Makassar': 8,   // WITA
  'Asia/Jayapura': 9,   // WIT
};

/// Kembalikan offset timezone dalam jam. Default WIB (+7) jika tidak dikenal.
int timezoneOffsetHours(String timezone) =>
    kTimezoneOffsets[timezone] ?? 7;

// ── Notification IDs & channels ───────────────────────────────────────────
/// Nama-nama sholat dalam urutan kalkulasi (untuk iterasi).
const kPrayerNames = ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya'];
