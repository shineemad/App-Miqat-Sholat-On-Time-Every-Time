import '../core/utils/app_logger.dart';
import '../data/cities/city_repository.dart';
import '../data/preferences/preferences_repository.dart';
import '../features/today/today_controller.dart';
import '../notifications/background_refresh_coordinator.dart';
import '../notifications/models/notification_settings.dart';
import '../notifications/prayer_notification_scheduler.dart';
import '../widgets/home_widget_service.dart';

/// Menyusun ulang notifikasi adzan & menyegarkan widget home screen.
///
/// Dipanggil saat cold start dan setiap kali preferensi yang memengaruhi
/// jadwal berubah (kota, metode, madzhab, offset, mode notifikasi) agar
/// perubahan langsung berlaku tanpa menunggu aplikasi dibuka ulang.
class ScheduleRefresher {
  ScheduleRefresher({
    required PreferencesRepository preferences,
    required CityRepository cityRepository,
    required NotificationSettingsRepository notificationSettings,
    required PrayerNotificationScheduler scheduler,
    required BackgroundRefreshCoordinator coordinator,
    required TodayController todayController,
    required HomeWidgetService homeWidget,
    required AppLogger logger,
  })  : _prefs = preferences,
        _cities = cityRepository,
        _notifSettings = notificationSettings,
        _scheduler = scheduler,
        _coordinator = coordinator,
        _today = todayController,
        _homeWidget = homeWidget,
        _logger = logger;

  final PreferencesRepository _prefs;
  final CityRepository _cities;
  final NotificationSettingsRepository _notifSettings;
  final PrayerNotificationScheduler _scheduler;
  final BackgroundRefreshCoordinator _coordinator;
  final TodayController _today;
  final HomeWidgetService _homeWidget;
  final AppLogger _logger;

  /// Reschedule notifikasi untuk kota & preferensi terkini.
  ///
  /// [force] melewati pengecekan "sudah dijadwalkan hari ini" — dipakai
  /// setelah pengguna mengubah pengaturan.
  Future<void> rescheduleNotifications({bool force = false}) async {
    try {
      if (!force && !_coordinator.shouldReschedule()) return;

      final city = await _cities.getById(_prefs.getSelectedCityId());
      if (city == null) return;

      await _scheduler.rescheduleAll(
        location: city.location,
        utcOffset: city.utcOffset,
        method: _prefs.getCalculationMethod(),
        madhab: _prefs.getMadhab(),
        settings: _notifSettings.load(),
        offsets: _prefs.getAllOffsets(),
        elevation: city.elevation,
      );
      await _coordinator.markRescheduled();
      _logger.info('Notifikasi sholat dijadwalkan ulang', tag: 'notif');
    } catch (e, s) {
      _logger.error('Gagal menjadwalkan notifikasi',
          error: e, stackTrace: s, tag: 'notif');
    }
  }

  /// Segarkan widget home screen dengan ringkasan terbaru.
  Future<void> refreshHomeWidget() async {
    try {
      final summary = await _today.loadToday();
      await _homeWidget.update(summary);
    } catch (e, s) {
      _logger.error('Gagal memperbarui widget',
          error: e, stackTrace: s, tag: 'widget');
    }
  }

  /// Terapkan perubahan pengaturan segera: notifikasi + widget.
  Future<void> applySettingsChange() async {
    await rescheduleNotifications(force: true);
    await refreshHomeWidget();
  }
}
