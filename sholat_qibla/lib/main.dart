import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/injection.dart';
import 'core/utils/app_logger.dart';
import 'data/cities/city_repository.dart';
import 'data/preferences/preferences_repository.dart';
import 'features/today/today_controller.dart';
import 'notifications/background_refresh_coordinator.dart';
import 'notifications/models/notification_settings.dart';
import 'notifications/notification_service.dart';
import 'notifications/prayer_notification_scheduler.dart';
import 'widgets/home_widget_service.dart';

/// Titik masuk aplikasi Miqat.
///
/// Alur cold start (dioptimalkan agar UI tampil cepat):
/// 1. Inisialisasi binding & dependency injection.
/// 2. Pasang error handling global (lokal saja, offline-first).
/// 3. Tampilkan UI.
/// 4. Jadwalkan notifikasi & minta izin secara asinkron (non-blocking).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await configureDependencies();
  final logger = sl<AppLogger>();

  // Error handling global — dicatat lokal, tidak dikirim ke server.
  FlutterError.onError = (details) {
    logger.error('FlutterError',
        error: details.exception, stackTrace: details.stack, tag: 'flutter');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Uncaught', error: error, stackTrace: stack, tag: 'platform');
    return true;
  };

  runApp(const MiqatApp());

  // Setup notifikasi setelah UI tampil agar tidak memperlambat cold start.
  unawaited(_setupNotifications(logger));

  // Segarkan widget home screen (Android) dengan jadwal terbaru.
  unawaited(_refreshHomeWidget(logger));
}

/// Menyegarkan widget home screen dengan ringkasan sholat hari ini.
Future<void> _refreshHomeWidget(AppLogger logger) async {
  try {
    final summary = await sl<TodayController>().loadToday();
    await sl<HomeWidgetService>().update(summary);
  } catch (e, s) {
    logger.error('Gagal memperbarui widget',
        error: e, stackTrace: s, tag: 'widget');
  }
}

/// Inisialisasi notifikasi & auto-reschedule harian untuk kota terpilih.
Future<void> _setupNotifications(AppLogger logger) async {
  try {
    final service = sl<NotificationService>();
    await service.initialize();
    await service.requestPermissions();

    final coordinator = sl<BackgroundRefreshCoordinator>();
    if (!coordinator.shouldReschedule()) return;

    final prefs = sl<PreferencesRepository>();
    final city =
        await sl<CityRepository>().getById(prefs.getSelectedCityId());
    if (city == null) return;

    await sl<PrayerNotificationScheduler>().rescheduleAll(
      location: city.location,
      utcOffset: city.utcOffset,
      method: prefs.getCalculationMethod(),
      madhab: prefs.getMadhab(),
      settings: sl<NotificationSettingsRepository>().load(),
      offsets: prefs.getAllOffsets(),
      elevation: city.elevation,
    );
    await coordinator.markRescheduled();
    logger.info('Notifikasi sholat dijadwalkan ulang', tag: 'notif');
  } catch (e, s) {
    logger.error('Gagal menyiapkan notifikasi',
        error: e, stackTrace: s, tag: 'notif');
  }
}
