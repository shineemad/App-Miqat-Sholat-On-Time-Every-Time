import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Miqat'**
  String get appName;

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari Ini'**
  String get today;

  /// No description provided for @qibla.
  ///
  /// In id, this message translates to:
  /// **'Kiblat'**
  String get qibla;

  /// No description provided for @quran.
  ///
  /// In id, this message translates to:
  /// **'Quran'**
  String get quran;

  /// No description provided for @hub.
  ///
  /// In id, this message translates to:
  /// **'Lainnya'**
  String get hub;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @subuh.
  ///
  /// In id, this message translates to:
  /// **'Subuh'**
  String get subuh;

  /// No description provided for @syuruk.
  ///
  /// In id, this message translates to:
  /// **'Syuruk'**
  String get syuruk;

  /// No description provided for @dzuhur.
  ///
  /// In id, this message translates to:
  /// **'Dzuhur'**
  String get dzuhur;

  /// No description provided for @ashar.
  ///
  /// In id, this message translates to:
  /// **'Ashar'**
  String get ashar;

  /// No description provided for @maghrib.
  ///
  /// In id, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// No description provided for @isya.
  ///
  /// In id, this message translates to:
  /// **'Isya'**
  String get isya;

  /// No description provided for @nextPrayer.
  ///
  /// In id, this message translates to:
  /// **'Sholat berikutnya'**
  String get nextPrayer;

  /// No description provided for @markedPrayed.
  ///
  /// In id, this message translates to:
  /// **'Sudah sholat'**
  String get markedPrayed;

  /// No description provided for @markPrayed.
  ///
  /// In id, this message translates to:
  /// **'Tandai sudah sholat'**
  String get markPrayed;

  /// No description provided for @locationGps.
  ///
  /// In id, this message translates to:
  /// **'GPS'**
  String get locationGps;

  /// No description provided for @locationManual.
  ///
  /// In id, this message translates to:
  /// **'Manual'**
  String get locationManual;

  /// No description provided for @offline.
  ///
  /// In id, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @calibrateCompass.
  ///
  /// In id, this message translates to:
  /// **'Kalibrasi Kompas'**
  String get calibrateCompass;

  /// No description provided for @calibrateInstruction.
  ///
  /// In id, this message translates to:
  /// **'Gerakkan ponsel membentuk angka 8 di udara beberapa kali, lalu coba lagi.'**
  String get calibrateInstruction;

  /// No description provided for @accuracyHigh.
  ///
  /// In id, this message translates to:
  /// **'Akurasi Tinggi'**
  String get accuracyHigh;

  /// No description provided for @accuracyMedium.
  ///
  /// In id, this message translates to:
  /// **'Akurasi Sedang'**
  String get accuracyMedium;

  /// No description provided for @accuracyLow.
  ///
  /// In id, this message translates to:
  /// **'Akurasi Rendah'**
  String get accuracyLow;

  /// No description provided for @qiblaDirection.
  ///
  /// In id, this message translates to:
  /// **'Arah Kiblat'**
  String get qiblaDirection;

  /// No description provided for @distanceToMakkah.
  ///
  /// In id, this message translates to:
  /// **'Jarak ke Makkah'**
  String get distanceToMakkah;

  /// No description provided for @km.
  ///
  /// In id, this message translates to:
  /// **'km'**
  String get km;

  /// No description provided for @degreesFromNorth.
  ///
  /// In id, this message translates to:
  /// **'° dari Utara'**
  String get degreesFromNorth;

  /// No description provided for @noMagnetometer.
  ///
  /// In id, this message translates to:
  /// **'Perangkat tidak memiliki sensor kompas.'**
  String get noMagnetometer;

  /// No description provided for @noMagnetometerInstruction.
  ///
  /// In id, this message translates to:
  /// **'Hadap arah {degrees}° dari Utara untuk menghadap kiblat.'**
  String noMagnetometerInstruction(String degrees);

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Sholat Tepat Waktu,\nPrivasi Terjaga'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Waktu sholat dan arah kiblat dihitung langsung di perangkat Anda — tanpa internet, tanpa akun, tanpa iklan.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @start.
  ///
  /// In id, this message translates to:
  /// **'Mulai'**
  String get start;

  /// No description provided for @onboardingLocationTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin Lokasi'**
  String get onboardingLocationTitle;

  /// No description provided for @onboardingLocationBody.
  ///
  /// In id, this message translates to:
  /// **'Aplikasi membutuhkan lokasi Anda untuk menghitung waktu sholat yang akurat. Lokasi tidak pernah dikirim ke server mana pun.'**
  String get onboardingLocationBody;

  /// No description provided for @useLocation.
  ///
  /// In id, this message translates to:
  /// **'Gunakan Lokasi (Saat Digunakan)'**
  String get useLocation;

  /// No description provided for @chooseCity.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kota Manual'**
  String get chooseCity;

  /// No description provided for @onboardingMethodTitle.
  ///
  /// In id, this message translates to:
  /// **'Metode Perhitungan'**
  String get onboardingMethodTitle;

  /// No description provided for @onboardingMethodBody.
  ///
  /// In id, this message translates to:
  /// **'Pilih metode yang sesuai dengan wilayah Anda.'**
  String get onboardingMethodBody;

  /// No description provided for @ashrMadhab.
  ///
  /// In id, this message translates to:
  /// **'Waktu Ashar'**
  String get ashrMadhab;

  /// No description provided for @shafiMadhab.
  ///
  /// In id, this message translates to:
  /// **'Syafi\'i (Bayangan 1×)'**
  String get shafiMadhab;

  /// No description provided for @hanafiMadhab.
  ///
  /// In id, this message translates to:
  /// **'Hanafi (Bayangan 2×)'**
  String get hanafiMadhab;

  /// No description provided for @onboardingNotifTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Adzan'**
  String get onboardingNotifTitle;

  /// No description provided for @onboardingNotifBody.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan notifikasi agar tidak melewatkan waktu sholat. Anda bisa mengatur per-sholat di Pengaturan.'**
  String get onboardingNotifBody;

  /// No description provided for @enableNotifications.
  ///
  /// In id, this message translates to:
  /// **'Aktifkan Notifikasi'**
  String get enableNotifications;

  /// No description provided for @skipForNow.
  ///
  /// In id, this message translates to:
  /// **'Lewati untuk Sekarang'**
  String get skipForNow;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get next;

  /// No description provided for @done.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get done;

  /// No description provided for @searchCity.
  ///
  /// In id, this message translates to:
  /// **'Cari kota...'**
  String get searchCity;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @settingsPrayer.
  ///
  /// In id, this message translates to:
  /// **'Waktu Sholat'**
  String get settingsPrayer;

  /// No description provided for @settingsNotifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get settingsNotifications;

  /// No description provided for @settingsLocation.
  ///
  /// In id, this message translates to:
  /// **'Lokasi'**
  String get settingsLocation;

  /// No description provided for @settingsDisplay.
  ///
  /// In id, this message translates to:
  /// **'Tampilan & Bahasa'**
  String get settingsDisplay;

  /// No description provided for @settingsPrivacy.
  ///
  /// In id, this message translates to:
  /// **'Privasi'**
  String get settingsPrivacy;

  /// No description provided for @settingsAbout.
  ///
  /// In id, this message translates to:
  /// **'Tentang'**
  String get settingsAbout;

  /// No description provided for @calculationMethod.
  ///
  /// In id, this message translates to:
  /// **'Metode Perhitungan'**
  String get calculationMethod;

  /// No description provided for @ashrMadhabLabel.
  ///
  /// In id, this message translates to:
  /// **'Madzhab Ashar'**
  String get ashrMadhabLabel;

  /// No description provided for @minuteCorrections.
  ///
  /// In id, this message translates to:
  /// **'Koreksi Menit'**
  String get minuteCorrections;

  /// No description provided for @hijriOffset.
  ///
  /// In id, this message translates to:
  /// **'Koreksi Tanggal Hijriah'**
  String get hijriOffset;

  /// No description provided for @notificationsEnabled.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi Aktif'**
  String get notificationsEnabled;

  /// No description provided for @notificationSound.
  ///
  /// In id, this message translates to:
  /// **'Suara'**
  String get notificationSound;

  /// No description provided for @soundAdhan.
  ///
  /// In id, this message translates to:
  /// **'Adzan'**
  String get soundAdhan;

  /// No description provided for @soundVibration.
  ///
  /// In id, this message translates to:
  /// **'Getaran'**
  String get soundVibration;

  /// No description provided for @soundSilent.
  ///
  /// In id, this message translates to:
  /// **'Senyap'**
  String get soundSilent;

  /// No description provided for @preAdhanReminder.
  ///
  /// In id, this message translates to:
  /// **'Pengingat Pra-Adzan'**
  String get preAdhanReminder;

  /// No description provided for @preAdhanOff.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get preAdhanOff;

  /// No description provided for @preAdhanMinutes.
  ///
  /// In id, this message translates to:
  /// **'{minutes} menit sebelum'**
  String preAdhanMinutes(int minutes);

  /// No description provided for @respectDnd.
  ///
  /// In id, this message translates to:
  /// **'Hormati Mode Senyap (DND)'**
  String get respectDnd;

  /// No description provided for @hideNotifContent.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan Konten di Lock Screen'**
  String get hideNotifContent;

  /// No description provided for @locationMode.
  ///
  /// In id, this message translates to:
  /// **'Mode Lokasi'**
  String get locationMode;

  /// No description provided for @locationModeGps.
  ///
  /// In id, this message translates to:
  /// **'GPS Otomatis'**
  String get locationModeGps;

  /// No description provided for @locationModeManual.
  ///
  /// In id, this message translates to:
  /// **'Pilih Kota Manual'**
  String get locationModeManual;

  /// No description provided for @revokeLocationPermission.
  ///
  /// In id, this message translates to:
  /// **'Kelola Izin Lokasi'**
  String get revokeLocationPermission;

  /// No description provided for @theme.
  ///
  /// In id, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In id, this message translates to:
  /// **'Ikuti Sistem'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In id, this message translates to:
  /// **'Terang'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In id, this message translates to:
  /// **'Gelap'**
  String get themeDark;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @textSize.
  ///
  /// In id, this message translates to:
  /// **'Ukuran Teks'**
  String get textSize;

  /// No description provided for @highContrast.
  ///
  /// In id, this message translates to:
  /// **'Kontras Tinggi'**
  String get highContrast;

  /// No description provided for @privacyBadge.
  ///
  /// In id, this message translates to:
  /// **'Data tidak meninggalkan perangkat'**
  String get privacyBadge;

  /// No description provided for @thirdPartyServices.
  ///
  /// In id, this message translates to:
  /// **'Layanan Pihak Ketiga'**
  String get thirdPartyServices;

  /// No description provided for @noThirdParty.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada'**
  String get noThirdParty;

  /// No description provided for @clearAllData.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua Data Lokal'**
  String get clearAllData;

  /// No description provided for @clearAllDataConfirm.
  ///
  /// In id, this message translates to:
  /// **'Yakin ingin menghapus semua data? Pengaturan akan kembali ke default.'**
  String get clearAllDataConfirm;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get confirm;

  /// No description provided for @appVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi Aplikasi'**
  String get appVersion;

  /// No description provided for @privacyPolicy.
  ///
  /// In id, this message translates to:
  /// **'Kebijakan Privasi'**
  String get privacyPolicy;

  /// No description provided for @credits.
  ///
  /// In id, this message translates to:
  /// **'Kredit'**
  String get credits;

  /// No description provided for @quranComingSoon.
  ///
  /// In id, this message translates to:
  /// **'Segera Hadir'**
  String get quranComingSoon;

  /// No description provided for @quranComingSoonDesc.
  ///
  /// In id, this message translates to:
  /// **'Fitur Al-Quran sedang dalam pengembangan dan akan tersedia di pembaruan berikutnya.'**
  String get quranComingSoonDesc;

  /// No description provided for @hubTitle.
  ///
  /// In id, this message translates to:
  /// **'Fitur Lainnya'**
  String get hubTitle;

  /// No description provided for @hubComingSoon.
  ///
  /// In id, this message translates to:
  /// **'Segera Hadir'**
  String get hubComingSoon;

  /// No description provided for @featureRamadan.
  ///
  /// In id, this message translates to:
  /// **'Mode Ramadhan'**
  String get featureRamadan;

  /// No description provided for @featureHijriCalendar.
  ///
  /// In id, this message translates to:
  /// **'Kalender Hijriah'**
  String get featureHijriCalendar;

  /// No description provided for @featureTasbih.
  ///
  /// In id, this message translates to:
  /// **'Tasbih Digital'**
  String get featureTasbih;

  /// No description provided for @featureMosqueFinder.
  ///
  /// In id, this message translates to:
  /// **'Pencari Masjid'**
  String get featureMosqueFinder;

  /// No description provided for @featureDailyDua.
  ///
  /// In id, this message translates to:
  /// **'Doa Harian'**
  String get featureDailyDua;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
