import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sholat_qibla/engine/models/prayer_times.dart';
import 'package:sholat_qibla/notifications/background_refresh_coordinator.dart';
import 'package:sholat_qibla/notifications/models/notification_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationSettingsRepository', () {
    Future<NotificationSettingsRepository> createRepo(
        [Map<String, Object> initial = const {}]) async {
      SharedPreferences.setMockInitialValues(initial);
      final prefs = await SharedPreferences.getInstance();
      return NotificationSettingsRepository(prefs);
    }

    test('default: mode adzan, 5 waktu aktif, sunrise nonaktif', () async {
      final repo = await createRepo();
      final settings = repo.load();
      expect(settings.mode, AdhanMode.adhan);
      expect(settings.enabledPrayers, NotificationSettings.defaultEnabled);
      expect(settings.isEnabled(Prayer.sunrise), isFalse);
      expect(settings.isEnabled(Prayer.fajr), isTrue);
      // Pengingat pra-adzan default aktif, jeda 10 menit.
      expect(settings.preAdhanEnabled, isTrue);
      expect(settings.preAdhanMinutes, 10);
    });

    test('save & load roundtrip', () async {
      final repo = await createRepo();
      await repo.save(const NotificationSettings(
        mode: AdhanMode.silent,
        enabledPrayers: {Prayer.fajr, Prayer.isha},
        preAdhanEnabled: false,
        preAdhanMinutes: 20,
      ));
      final loaded = repo.load();
      expect(loaded.mode, AdhanMode.silent);
      expect(loaded.enabledPrayers, {Prayer.fajr, Prayer.isha});
      expect(loaded.preAdhanEnabled, isFalse);
      expect(loaded.preAdhanMinutes, 20);
    });

    test('nilai tersimpan tak dikenal diabaikan dengan aman', () async {
      final repo = await createRepo({
        'notif_mode': 'mode_aneh',
        'notif_enabled_prayers': ['fajr', 'sholat_baru'],
      });
      final settings = repo.load();
      expect(settings.mode, AdhanMode.adhan);
      expect(settings.enabledPrayers, {Prayer.fajr});
    });

    test('copyWith mengubah sebagian field', () {
      const base = NotificationSettings();
      final changed = base.copyWith(mode: AdhanMode.vibrate);
      expect(changed.mode, AdhanMode.vibrate);
      expect(changed.enabledPrayers, base.enabledPrayers);
    });
  });

  group('BackgroundRefreshCoordinator', () {
    test('perlu reschedule saat belum pernah dijadwalkan', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final coordinator = BackgroundRefreshCoordinator(prefs);
      expect(coordinator.shouldReschedule(), isTrue);
    });

    test('tidak reschedule dua kali pada hari yang sama', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime(2026, 7, 3, 6, 0);
      final coordinator =
          BackgroundRefreshCoordinator(prefs, clock: () => today);

      await coordinator.markRescheduled();
      expect(coordinator.shouldReschedule(), isFalse);
    });

    test('perlu reschedule lagi di hari berikutnya', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      var now = DateTime(2026, 7, 3, 6, 0);
      final coordinator =
          BackgroundRefreshCoordinator(prefs, clock: () => now);

      await coordinator.markRescheduled();
      expect(coordinator.shouldReschedule(), isFalse);

      now = DateTime(2026, 7, 4, 0, 5); // lewat tengah malam
      expect(coordinator.shouldReschedule(), isTrue);
    });

    test('invalidate memaksa reschedule berikutnya', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final coordinator = BackgroundRefreshCoordinator(prefs);

      await coordinator.markRescheduled();
      expect(coordinator.shouldReschedule(), isFalse);

      await coordinator.invalidate();
      expect(coordinator.shouldReschedule(), isTrue);
    });
  });
}
