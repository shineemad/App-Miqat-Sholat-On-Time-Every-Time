import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/utils/app_logger.dart';
import '../data/cities/city_repository.dart';
import '../data/location/location_service.dart';
import '../data/preferences/preferences_repository.dart';
import '../features/hub/tasbih_counter.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/qibla/qibla_compass_service.dart';
import '../features/qibla/qibla_controller.dart';
import '../features/quran/quran_bookmark_repository.dart';
import '../features/quran/quran_controller.dart';
import '../features/quran/quran_repository.dart';
import '../features/settings/settings_controller.dart';
import '../features/today/today_controller.dart';
import '../notifications/background_refresh_coordinator.dart';
import '../notifications/models/notification_settings.dart';
import '../notifications/notification_service.dart';
import '../notifications/prayer_notification_scheduler.dart';

/// Service locator global.
final GetIt sl = GetIt.instance;

/// Mendaftarkan seluruh dependency aplikasi.
///
/// Mengintegrasikan modul ketiga anggota tim:
/// - Orang 1: engine waktu sholat, data lokasi/kota, preferensi.
/// - Orang 2: kompas kiblat, notifikasi & background service.
/// - Orang 3: Quran, Hub, controller integrasi.
///
/// Idempoten: aman dipanggil ulang (mis. pada test) selama [reset]
/// dijalankan lebih dulu.
Future<void> configureDependencies({
  SharedPreferences? sharedPreferences,
  LocationService? locationService,
}) async {
  final prefs = sharedPreferences ?? await SharedPreferences.getInstance();

  // --- Core ---
  sl.registerSingleton<SharedPreferences>(prefs);
  sl.registerLazySingleton<AppLogger>(() => AppLogger());

  // --- Orang 1: data & engine ---
  sl.registerSingleton<PreferencesRepository>(
    await PreferencesRepository.create(prefs: prefs),
  );
  sl.registerLazySingleton<CityRepository>(() => CityRepository());
  sl.registerLazySingleton<LocationService>(
    () => locationService ?? const GeolocatorLocationService(),
  );

  // --- Orang 2: kiblat & notifikasi ---
  sl.registerLazySingleton<NotificationSettingsRepository>(
    () => NotificationSettingsRepository(prefs),
  );
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<PrayerNotificationScheduler>(
    () => PrayerNotificationScheduler(gateway: sl<NotificationService>()),
  );
  sl.registerLazySingleton<BackgroundRefreshCoordinator>(
    () => BackgroundRefreshCoordinator(prefs),
  );

  // --- Orang 3: Quran & Hub ---
  sl.registerLazySingleton<QuranRepository>(() => QuranRepository());
  sl.registerSingleton<QuranBookmarkRepository>(
    QuranBookmarkRepository(prefs),
  );
  sl.registerFactory<TasbihCounter>(() => TasbihCounter(prefs));

  sl.registerFactory<QuranController>(
    () => QuranController(
      repository: sl<QuranRepository>(),
      bookmarks: sl<QuranBookmarkRepository>(),
    ),
  );

  // --- Controllers integrasi ---
  sl.registerFactory<TodayController>(
    () => TodayController(
      locationService: sl<LocationService>(),
      cityRepository: sl<CityRepository>(),
      preferences: sl<PreferencesRepository>(),
    ),
  );
  sl.registerFactory<QiblaController>(
    () => QiblaController(
      locationService: sl<LocationService>(),
      cityRepository: sl<CityRepository>(),
      preferences: sl<PreferencesRepository>(),
      compassSource: const FlutterCompassSource(),
    ),
  );
  sl.registerFactory<OnboardingController>(
    () => OnboardingController(sl<PreferencesRepository>()),
  );
  sl.registerFactory<SettingsController>(
    () => SettingsController(
      preferences: sl<PreferencesRepository>(),
      notificationSettings: sl<NotificationSettingsRepository>(),
      cityRepository: sl<CityRepository>(),
      refreshCoordinator: sl<BackgroundRefreshCoordinator>(),
    ),
  );
}

/// Membersihkan semua registrasi (dipakai pada test).
Future<void> resetDependencies() => sl.reset();
