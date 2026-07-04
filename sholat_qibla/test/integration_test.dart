import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/app/injection.dart';
import 'package:sholat_qibla/data/cities/city_repository.dart';
import 'package:sholat_qibla/data/location/location_service.dart';
import 'package:sholat_qibla/data/preferences/preferences_repository.dart';
import 'package:sholat_qibla/engine/models/calculation_method.dart';
import 'package:sholat_qibla/engine/models/lat_lng.dart';
import 'package:sholat_qibla/engine/models/madhab.dart';
import 'package:sholat_qibla/features/onboarding/onboarding_controller.dart';
import 'package:sholat_qibla/features/today/today_controller.dart';
import 'package:sholat_qibla/features/quran/quran_repository.dart';

/// Location service palsu untuk integration test (tanpa GPS asli).
class _FakeLocationService implements LocationService {
  _FakeLocationService(this._result);
  final LocationResult _result;

  @override
  Future<LocationResult> getCurrentLocation() async => _result;

  @override
  Future<LatLng?> getLastKnownLocation() async {
    final result = _result;
    return result is LocationSuccess ? result.position : null;
  }

  @override
  Future<bool> isServiceEnabled() async => _result is LocationSuccess;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() async {
    if (sl.isRegistered<PreferencesRepository>() ||
        sl.isRegistered<SharedPreferences>()) {
      await resetDependencies();
    }
  });

  group('Dependency Injection', () {
    test('semua service inti terdaftar & dapat di-resolve', () async {
      SharedPreferences.setMockInitialValues({});
      await configureDependencies(
        locationService: _FakeLocationService(
          const LocationFailure(LocationFailureReason.serviceDisabled),
        ),
      );

      // Modul Orang 1, 2, 3 semuanya ter-resolve.
      expect(sl<PreferencesRepository>(), isNotNull);
      expect(sl<CityRepository>(), isNotNull);
      expect(sl<QuranRepository>(), isNotNull);
      expect(sl<TodayController>(), isNotNull);
      expect(sl<OnboardingController>(), isNotNull);
    });

    test('factory menghasilkan instance baru, singleton tidak', () async {
      SharedPreferences.setMockInitialValues({});
      await configureDependencies(
        locationService: _FakeLocationService(
          const LocationFailure(LocationFailureReason.serviceDisabled),
        ),
      );
      expect(identical(sl<TodayController>(), sl<TodayController>()), isFalse);
      expect(identical(sl<CityRepository>(), sl<CityRepository>()), isTrue);
    });
  });

  group('TodayController - integrasi engine + data + preferensi', () {
    Future<TodayController> makeController({
      required LocationResult location,
      Map<String, Object> prefs = const {},
    }) async {
      SharedPreferences.setMockInitialValues(prefs);
      final sp = await SharedPreferences.getInstance();
      return TodayController(
        locationService: _FakeLocationService(location),
        cityRepository: CityRepository(),
        preferences: await PreferencesRepository.create(prefs: sp),
      );
    }

    test('memakai GPS -> reverse geocode ke kota terdekat', () async {
      final controller = await makeController(
        location: const LocationSuccess(LatLng(-6.20, 106.82)),
        prefs: {'use_gps': true},
      );
      final summary = await controller.loadToday(now: DateTime(2026, 7, 3, 10));
      expect(summary.locationSource, LocationSource.gps);
      expect(summary.city.id, 'jakarta');
      // Urutan waktu valid (bukti engine terintegrasi).
      expect(summary.prayerTimes.fajr.isBefore(summary.prayerTimes.dhuhr),
          isTrue);
      expect(summary.nextPrayer, isNotNull);
    });

    test('GPS gagal -> fallback ke kota terpilih', () async {
      final controller = await makeController(
        location: const LocationFailure(LocationFailureReason.permissionDenied),
        prefs: {'use_gps': true, 'city_id': 'bandung'},
      );
      final summary = await controller.loadToday(now: DateTime(2026, 7, 3, 10));
      expect(summary.locationSource, LocationSource.manualCity);
      expect(summary.city.id, 'bandung');
    });

    test('mode non-GPS memakai kota terpilih langsung', () async {
      final controller = await makeController(
        location: const LocationFailure(LocationFailureReason.serviceDisabled),
        prefs: {'use_gps': false, 'city_id': 'surabaya'},
      );
      final summary = await controller.loadToday(now: DateTime(2026, 7, 3, 10));
      expect(summary.city.id, 'surabaya');
      expect(summary.locationSource, LocationSource.manualCity);
    });

    test('preferensi metode & offset diterapkan pada hasil', () async {
      final base = await (await makeController(
        location: const LocationFailure(LocationFailureReason.serviceDisabled),
        prefs: {'use_gps': false, 'city_id': 'jakarta'},
      ))
          .loadToday(now: DateTime(2026, 7, 3, 3));

      final shifted = await (await makeController(
        location: const LocationFailure(LocationFailureReason.serviceDisabled),
        prefs: {
          'use_gps': false,
          'city_id': 'jakarta',
          'calc_method': CalculationMethod.mwl.name,
          'madhab': Madhab.hanafi.name,
          'offset_fajr': 5,
        },
      ))
          .loadToday(now: DateTime(2026, 7, 3, 3));

      // Offset fajr +5 menit terlihat pada perbedaan waktu.
      final diff = shifted.prayerTimes.fajr
          .difference(base.prayerTimes.fajr)
          .inMinutes;
      // MWL (18°) vs Kemenag (20°) + offset 5 => fajr bergeser.
      expect(diff, isNot(0));
      // Hanafi membuat ashar lebih lambat dari Syafii.
      expect(shifted.prayerTimes.asr.isAfter(base.prayerTimes.asr), isTrue);
    });
  });

  group('OnboardingController - integrasi', () {
    Future<OnboardingController> makeController(
        [Map<String, Object> prefs = const {}]) async {
      SharedPreferences.setMockInitialValues(prefs);
      final sp = await SharedPreferences.getInstance();
      return OnboardingController(await PreferencesRepository.create(prefs: sp));
    }

    test('first run terdeteksi lalu selesai permanen', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final prefs = await PreferencesRepository.create(prefs: sp);
      final controller = OnboardingController(prefs);

      expect(controller.isFirstRun, isTrue);
      await controller.complete();
      expect(prefs.isOnboardingDone(), isTrue);
      expect(OnboardingController(prefs).isFirstRun, isFalse);
    });

    test('navigasi langkah maju-mundur', () async {
      final controller = await makeController();
      expect(controller.currentStep, OnboardingStep.welcome);
      expect(controller.next(), OnboardingStep.location);
      expect(controller.next(), OnboardingStep.method);
      expect(controller.previous(), OnboardingStep.location);
    });

    test('pilihan awal tersimpan ke preferensi', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final prefs = await PreferencesRepository.create(prefs: sp);
      final controller = OnboardingController(prefs);

      await controller.chooseCity('medan');
      await controller.chooseMethod(CalculationMethod.isna);
      await controller.chooseMadhab(Madhab.hanafi);

      expect(prefs.getSelectedCityId(), 'medan');
      expect(prefs.getUseGps(), isFalse);
      expect(prefs.getCalculationMethod(), CalculationMethod.isna);
      expect(prefs.getMadhab(), Madhab.hanafi);
    });
  });

  group('End-to-end: onboarding -> beranda', () {
    test('alur lengkap pengguna baru menghasilkan jadwal valid', () async {
      SharedPreferences.setMockInitialValues({});
      final sp = await SharedPreferences.getInstance();
      final prefs = await PreferencesRepository.create(prefs: sp);

      // 1. Onboarding: pilih kota & metode, selesaikan.
      final onboarding = OnboardingController(prefs);
      await onboarding.chooseCity('yogyakarta');
      await onboarding.chooseMethod(CalculationMethod.kemenag);
      await onboarding.complete();

      // 2. Buka Beranda: controller memakai preferensi tadi.
      final today = TodayController(
        locationService: _FakeLocationService(
          const LocationFailure(LocationFailureReason.serviceDisabled),
        ),
        cityRepository: CityRepository(),
        preferences: prefs,
      );
      final summary = await today.loadToday(now: DateTime(2026, 7, 3, 5));

      expect(prefs.isOnboardingDone(), isTrue);
      expect(summary.city.id, 'yogyakarta');
      final t = summary.prayerTimes;
      expect(t.fajr.isBefore(t.sunrise), isTrue);
      expect(t.maghrib.isBefore(t.isha), isTrue);
    });
  });
}
