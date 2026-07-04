import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/data/preferences/preferences_repository.dart';
import 'package:sholat_qibla/engine/models/calculation_method.dart';
import 'package:sholat_qibla/engine/models/madhab.dart';
import 'package:sholat_qibla/engine/models/prayer_times.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PreferencesRepository> createRepo(
      [Map<String, Object> initial = const {}]) async {
    SharedPreferences.setMockInitialValues(initial);
    final prefs = await SharedPreferences.getInstance();
    return PreferencesRepository.create(prefs: prefs);
  }

  group('PreferencesRepository - nilai default', () {
    test('default sesuai konstanta aplikasi', () async {
      final repo = await createRepo();
      expect(repo.getCalculationMethod(), CalculationMethod.kemenag);
      expect(repo.getMadhab(), Madhab.shafi);
      expect(repo.getSelectedCityId(), 'jakarta');
      expect(repo.getUseGps(), isTrue);
      expect(repo.isOnboardingDone(), isFalse);
      for (final p in Prayer.values) {
        expect(repo.getOffset(p), 0);
      }
    });
  });

  group('PreferencesRepository - simpan & baca', () {
    test('metode kalkulasi', () async {
      final repo = await createRepo();
      await repo.setCalculationMethod(CalculationMethod.mwl);
      expect(repo.getCalculationMethod(), CalculationMethod.mwl);
    });

    test('madzhab', () async {
      final repo = await createRepo();
      await repo.setMadhab(Madhab.hanafi);
      expect(repo.getMadhab(), Madhab.hanafi);
    });

    test('kota terpilih & mode GPS', () async {
      final repo = await createRepo();
      await repo.setSelectedCityId('bandung');
      await repo.setUseGps(false);
      expect(repo.getSelectedCityId(), 'bandung');
      expect(repo.getUseGps(), isFalse);
    });

    test('offset per waktu sholat', () async {
      final repo = await createRepo();
      await repo.setOffset(Prayer.fajr, 2);
      await repo.setOffset(Prayer.maghrib, -1);
      expect(repo.getOffset(Prayer.fajr), 2);
      expect(repo.getOffset(Prayer.maghrib), -1);
      expect(repo.getOffset(Prayer.dhuhr), 0);

      final all = repo.getAllOffsets();
      expect(all[Prayer.fajr], 2);
      expect(all[Prayer.maghrib], -1);
      expect(all.length, Prayer.values.length);
    });

    test('status onboarding', () async {
      final repo = await createRepo();
      await repo.setOnboardingDone();
      expect(repo.isOnboardingDone(), isTrue);
    });
  });

  group('PreferencesRepository - migrasi schema', () {
    test('v0 -> v1: method_index (int) dimigrasi ke nama enum', () async {
      // Data lama: metode disimpan sebagai index (1 = mwl).
      final repo = await createRepo({'method_index': 1});
      expect(repo.getCalculationMethod(), CalculationMethod.mwl);

      // Kunci lama dihapus dan versi schema tercatat.
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('method_index'), isNull);
      expect(prefs.getInt('schema_version'),
          PreferencesRepository.schemaVersion);
    });

    test('v0 -> v1: index tidak valid jatuh ke default kemenag', () async {
      final repo = await createRepo({'method_index': 99});
      expect(repo.getCalculationMethod(), CalculationMethod.kemenag);
    });

    test('migrasi tidak berjalan ulang jika schema sudah terbaru', () async {
      SharedPreferences.setMockInitialValues({
        'schema_version': PreferencesRepository.schemaVersion,
        'method_index': 1, // seharusnya diabaikan (tidak dimigrasi)
        'calc_method': 'isna',
      });
      final prefs = await SharedPreferences.getInstance();
      final repo = await PreferencesRepository.create(prefs: prefs);
      expect(repo.getCalculationMethod(), CalculationMethod.isna);
      expect(prefs.getInt('method_index'), 1);
    });

    test('nilai tersimpan tak dikenal jatuh ke default', () async {
      final repo = await createRepo({
        'schema_version': PreferencesRepository.schemaVersion,
        'calc_method': 'metode_masa_depan',
        'madhab': 'tidak_ada',
      });
      expect(repo.getCalculationMethod(), CalculationMethod.kemenag);
      expect(repo.getMadhab(), Madhab.shafi);
    });
  });
}
