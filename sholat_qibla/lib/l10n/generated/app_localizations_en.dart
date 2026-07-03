// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Miqat';

  @override
  String get today => 'Today';

  @override
  String get qibla => 'Qibla';

  @override
  String get quran => 'Quran';

  @override
  String get hub => 'More';

  @override
  String get settings => 'Settings';

  @override
  String get subuh => 'Fajr';

  @override
  String get syuruk => 'Sunrise';

  @override
  String get dzuhur => 'Dhuhr';

  @override
  String get ashar => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isya => 'Isha';

  @override
  String get nextPrayer => 'Next prayer';

  @override
  String get markedPrayed => 'Prayed';

  @override
  String get markPrayed => 'Mark as prayed';

  @override
  String get locationGps => 'GPS';

  @override
  String get locationManual => 'Manual';

  @override
  String get offline => 'Offline';

  @override
  String get calibrateCompass => 'Calibrate Compass';

  @override
  String get calibrateInstruction =>
      'Move your phone in a figure-8 pattern a few times, then try again.';

  @override
  String get accuracyHigh => 'High Accuracy';

  @override
  String get accuracyMedium => 'Medium Accuracy';

  @override
  String get accuracyLow => 'Low Accuracy';

  @override
  String get qiblaDirection => 'Qibla Direction';

  @override
  String get distanceToMakkah => 'Distance to Makkah';

  @override
  String get km => 'km';

  @override
  String get degreesFromNorth => '° from North';

  @override
  String get noMagnetometer => 'Device has no compass sensor.';

  @override
  String noMagnetometerInstruction(String degrees) {
    return 'Face $degrees° from North to face the Qibla.';
  }

  @override
  String get onboardingWelcomeTitle => 'Pray On Time,\nPrivacy Protected';

  @override
  String get onboardingWelcomeSubtitle =>
      'Prayer times and Qibla direction are calculated directly on your device — no internet, no account, no ads.';

  @override
  String get start => 'Get Started';

  @override
  String get onboardingLocationTitle => 'Location Permission';

  @override
  String get onboardingLocationBody =>
      'The app needs your location to calculate accurate prayer times. Your location is never sent to any server.';

  @override
  String get useLocation => 'Use Location (While Using)';

  @override
  String get chooseCity => 'Choose City Manually';

  @override
  String get onboardingMethodTitle => 'Calculation Method';

  @override
  String get onboardingMethodBody =>
      'Choose the method that suits your region.';

  @override
  String get ashrMadhab => 'Asr Time';

  @override
  String get shafiMadhab => 'Shafi\'i (Shadow 1×)';

  @override
  String get hanafiMadhab => 'Hanafi (Shadow 2×)';

  @override
  String get onboardingNotifTitle => 'Prayer Reminders';

  @override
  String get onboardingNotifBody =>
      'Enable notifications so you never miss prayer time. You can adjust per-prayer settings later.';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get searchCity => 'Search city...';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrayer => 'Prayer Times';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsDisplay => 'Display & Language';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsAbout => 'About';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get ashrMadhabLabel => 'Asr Madhab';

  @override
  String get minuteCorrections => 'Minute Corrections';

  @override
  String get hijriOffset => 'Hijri Date Offset';

  @override
  String get notificationsEnabled => 'Notifications Enabled';

  @override
  String get notificationSound => 'Sound';

  @override
  String get soundAdhan => 'Adhan';

  @override
  String get soundVibration => 'Vibration';

  @override
  String get soundSilent => 'Silent';

  @override
  String get preAdhanReminder => 'Pre-Adhan Reminder';

  @override
  String get preAdhanOff => 'Off';

  @override
  String preAdhanMinutes(int minutes) {
    return '$minutes minutes before';
  }

  @override
  String get respectDnd => 'Respect Do Not Disturb';

  @override
  String get hideNotifContent => 'Hide Content on Lock Screen';

  @override
  String get locationMode => 'Location Mode';

  @override
  String get locationModeGps => 'Automatic GPS';

  @override
  String get locationModeManual => 'Choose City Manually';

  @override
  String get revokeLocationPermission => 'Manage Location Permission';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System Default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get language => 'Language';

  @override
  String get textSize => 'Text Size';

  @override
  String get highContrast => 'High Contrast';

  @override
  String get privacyBadge => 'Data stays on your device';

  @override
  String get thirdPartyServices => 'Third-Party Services';

  @override
  String get noThirdParty => 'None';

  @override
  String get clearAllData => 'Clear All Local Data';

  @override
  String get clearAllDataConfirm =>
      'Are you sure you want to clear all data? Settings will reset to defaults.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Delete';

  @override
  String get appVersion => 'App Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get credits => 'Credits';

  @override
  String get quranComingSoon => 'Coming Soon';

  @override
  String get quranComingSoonDesc =>
      'The Quran feature is under development and will be available in the next update.';

  @override
  String get hubTitle => 'More Features';

  @override
  String get hubComingSoon => 'Coming Soon';

  @override
  String get featureRamadan => 'Ramadan Mode';

  @override
  String get featureHijriCalendar => 'Hijri Calendar';

  @override
  String get featureTasbih => 'Digital Tasbih';

  @override
  String get featureMosqueFinder => 'Mosque Finder';

  @override
  String get featureDailyDua => 'Daily Duas';
}
