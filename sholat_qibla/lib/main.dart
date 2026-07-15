import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/injection.dart';
import 'core/utils/app_logger.dart';
import 'notifications/notification_service.dart';
import 'notifications/schedule_refresher.dart';

/// Titik masuk aplikasi MU-Qibla.
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

  runApp(const MuQiblaApp());

  // Setup notifikasi & widget setelah UI tampil (non-blocking).
  unawaited(_setupNotifications(logger));
}

/// Inisialisasi notifikasi, auto-reschedule harian & refresh widget.
Future<void> _setupNotifications(AppLogger logger) async {
  try {
    final service = sl<NotificationService>();
    await service.initialize();
    await service.requestPermissions();

    final refresher = sl<ScheduleRefresher>();
    await refresher.rescheduleNotifications();
    await refresher.refreshHomeWidget();
  } catch (e, s) {
    logger.error('Gagal menyiapkan notifikasi',
        error: e, stackTrace: s, tag: 'notif');
  }
}
