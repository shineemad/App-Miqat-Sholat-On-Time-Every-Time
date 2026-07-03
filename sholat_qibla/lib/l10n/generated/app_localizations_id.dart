// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Miqat';

  @override
  String get today => 'Hari Ini';

  @override
  String get qibla => 'Kiblat';

  @override
  String get quran => 'Quran';

  @override
  String get hub => 'Lainnya';

  @override
  String get settings => 'Pengaturan';

  @override
  String get subuh => 'Subuh';

  @override
  String get syuruk => 'Syuruk';

  @override
  String get dzuhur => 'Dzuhur';

  @override
  String get ashar => 'Ashar';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isya => 'Isya';

  @override
  String get nextPrayer => 'Sholat berikutnya';

  @override
  String get markedPrayed => 'Sudah sholat';

  @override
  String get markPrayed => 'Tandai sudah sholat';

  @override
  String get locationGps => 'GPS';

  @override
  String get locationManual => 'Manual';

  @override
  String get offline => 'Offline';

  @override
  String get calibrateCompass => 'Kalibrasi Kompas';

  @override
  String get calibrateInstruction =>
      'Gerakkan ponsel membentuk angka 8 di udara beberapa kali, lalu coba lagi.';

  @override
  String get accuracyHigh => 'Akurasi Tinggi';

  @override
  String get accuracyMedium => 'Akurasi Sedang';

  @override
  String get accuracyLow => 'Akurasi Rendah';

  @override
  String get qiblaDirection => 'Arah Kiblat';

  @override
  String get distanceToMakkah => 'Jarak ke Makkah';

  @override
  String get km => 'km';

  @override
  String get degreesFromNorth => '° dari Utara';

  @override
  String get noMagnetometer => 'Perangkat tidak memiliki sensor kompas.';

  @override
  String noMagnetometerInstruction(String degrees) {
    return 'Hadap arah $degrees° dari Utara untuk menghadap kiblat.';
  }

  @override
  String get onboardingWelcomeTitle => 'Sholat Tepat Waktu,\nPrivasi Terjaga';

  @override
  String get onboardingWelcomeSubtitle =>
      'Waktu sholat dan arah kiblat dihitung langsung di perangkat Anda — tanpa internet, tanpa akun, tanpa iklan.';

  @override
  String get start => 'Mulai';

  @override
  String get onboardingLocationTitle => 'Izin Lokasi';

  @override
  String get onboardingLocationBody =>
      'Aplikasi membutuhkan lokasi Anda untuk menghitung waktu sholat yang akurat. Lokasi tidak pernah dikirim ke server mana pun.';

  @override
  String get useLocation => 'Gunakan Lokasi (Saat Digunakan)';

  @override
  String get chooseCity => 'Pilih Kota Manual';

  @override
  String get onboardingMethodTitle => 'Metode Perhitungan';

  @override
  String get onboardingMethodBody =>
      'Pilih metode yang sesuai dengan wilayah Anda.';

  @override
  String get ashrMadhab => 'Waktu Ashar';

  @override
  String get shafiMadhab => 'Syafi\'i (Bayangan 1×)';

  @override
  String get hanafiMadhab => 'Hanafi (Bayangan 2×)';

  @override
  String get onboardingNotifTitle => 'Pengingat Adzan';

  @override
  String get onboardingNotifBody =>
      'Aktifkan notifikasi agar tidak melewatkan waktu sholat. Anda bisa mengatur per-sholat di Pengaturan.';

  @override
  String get enableNotifications => 'Aktifkan Notifikasi';

  @override
  String get skipForNow => 'Lewati untuk Sekarang';

  @override
  String get next => 'Lanjut';

  @override
  String get done => 'Selesai';

  @override
  String get searchCity => 'Cari kota...';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsPrayer => 'Waktu Sholat';

  @override
  String get settingsNotifications => 'Notifikasi';

  @override
  String get settingsLocation => 'Lokasi';

  @override
  String get settingsDisplay => 'Tampilan & Bahasa';

  @override
  String get settingsPrivacy => 'Privasi';

  @override
  String get settingsAbout => 'Tentang';

  @override
  String get calculationMethod => 'Metode Perhitungan';

  @override
  String get ashrMadhabLabel => 'Madzhab Ashar';

  @override
  String get minuteCorrections => 'Koreksi Menit';

  @override
  String get hijriOffset => 'Koreksi Tanggal Hijriah';

  @override
  String get notificationsEnabled => 'Notifikasi Aktif';

  @override
  String get notificationSound => 'Suara';

  @override
  String get soundAdhan => 'Adzan';

  @override
  String get soundVibration => 'Getaran';

  @override
  String get soundSilent => 'Senyap';

  @override
  String get preAdhanReminder => 'Pengingat Pra-Adzan';

  @override
  String get preAdhanOff => 'Nonaktif';

  @override
  String preAdhanMinutes(int minutes) {
    return '$minutes menit sebelum';
  }

  @override
  String get respectDnd => 'Hormati Mode Senyap (DND)';

  @override
  String get hideNotifContent => 'Sembunyikan Konten di Lock Screen';

  @override
  String get locationMode => 'Mode Lokasi';

  @override
  String get locationModeGps => 'GPS Otomatis';

  @override
  String get locationModeManual => 'Pilih Kota Manual';

  @override
  String get revokeLocationPermission => 'Kelola Izin Lokasi';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Ikuti Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

  @override
  String get language => 'Bahasa';

  @override
  String get textSize => 'Ukuran Teks';

  @override
  String get highContrast => 'Kontras Tinggi';

  @override
  String get privacyBadge => 'Data tidak meninggalkan perangkat';

  @override
  String get thirdPartyServices => 'Layanan Pihak Ketiga';

  @override
  String get noThirdParty => 'Tidak ada';

  @override
  String get clearAllData => 'Hapus Semua Data Lokal';

  @override
  String get clearAllDataConfirm =>
      'Yakin ingin menghapus semua data? Pengaturan akan kembali ke default.';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Hapus';

  @override
  String get appVersion => 'Versi Aplikasi';

  @override
  String get privacyPolicy => 'Kebijakan Privasi';

  @override
  String get credits => 'Kredit';

  @override
  String get quranComingSoon => 'Segera Hadir';

  @override
  String get quranComingSoonDesc =>
      'Fitur Al-Quran sedang dalam pengembangan dan akan tersedia di pembaruan berikutnya.';

  @override
  String get hubTitle => 'Fitur Lainnya';

  @override
  String get hubComingSoon => 'Segera Hadir';

  @override
  String get featureRamadan => 'Mode Ramadhan';

  @override
  String get featureHijriCalendar => 'Kalender Hijriah';

  @override
  String get featureTasbih => 'Tasbih Digital';

  @override
  String get featureMosqueFinder => 'Pencari Masjid';

  @override
  String get featureDailyDua => 'Doa Harian';
}
