import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'models/notification_settings.dart';
import 'prayer_notification_scheduler.dart';

/// Layanan notifikasi berbasis flutter_local_notifications.
///
/// Bertanggung jawab atas: inisialisasi plugin, channel Android
/// (adzan / silent / getar), permission (Android 13+ & iOS), dan
/// eksekusi penjadwalan exact alarm.
class NotificationService implements NotificationGateway {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  // Channel Android per mode.
  static const _adhanChannel = AndroidNotificationDetails(
    'adhan_channel',
    'Adzan',
    channelDescription: 'Notifikasi waktu sholat dengan suara adzan',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('adzan'),
    playSound: true,
    enableVibration: true,
    category: AndroidNotificationCategory.alarm,
  );

  static const _silentChannel = AndroidNotificationDetails(
    'silent_channel',
    'Notifikasi Senyap',
    channelDescription: 'Notifikasi waktu sholat tanpa suara',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
    playSound: false,
    enableVibration: false,
  );

  static const _vibrateChannel = AndroidNotificationDetails(
    'vibrate_channel',
    'Notifikasi Getar',
    channelDescription: 'Notifikasi waktu sholat dengan getaran saja',
    importance: Importance.high,
    priority: Priority.high,
    playSound: false,
    enableVibration: true,
  );

  // Channel pengingat pra-adzan dengan suara alarm (~7 detik).
  static const _reminderChannel = AndroidNotificationDetails(
    'reminder_channel',
    'Pengingat Pra-Adzan',
    channelDescription: 'Alarm beberapa menit sebelum waktu sholat',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('alarm'),
    playSound: true,
    enableVibration: true,
    category: AndroidNotificationCategory.alarm,
  );

  /// Inisialisasi plugin & database zona waktu. Idempoten.
  Future<void> initialize() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        // Permission diminta eksplisit lewat requestPermissions().
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Meminta permission notifikasi (Android 13+ / iOS) dan exact alarm
  /// (Android 12+). Mengembalikan true bila notifikasi diizinkan.
  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      // Exact alarm untuk ketepatan waktu adzan (Android 12+).
      await android.requestExactAlarmsPermission();
      return granted;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    return false;
  }

  NotificationDetails _detailsForNotification(
      ScheduledPrayerNotification n) {
    // Pengingat pra-adzan selalu memakai suara alarm.
    if (n.kind == NotificationKind.reminder) {
      return const NotificationDetails(
        android: _reminderChannel,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          sound: 'alarm.aiff',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );
    }
    return _detailsFor(n.mode);
  }

  NotificationDetails _detailsFor(AdhanMode mode) => switch (mode) {
        AdhanMode.adhan => const NotificationDetails(
            android: _adhanChannel,
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
              sound: 'adzan.aiff',
              interruptionLevel: InterruptionLevel.timeSensitive,
            ),
          ),
        AdhanMode.silent => const NotificationDetails(
            android: _silentChannel,
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: false,
            ),
          ),
        AdhanMode.vibrate => const NotificationDetails(
            android: _vibrateChannel,
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: false,
            ),
          ),
      };

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<void> schedule(ScheduledPrayerNotification notification) async {
    await initialize();
    await _plugin.zonedSchedule(
      notification.id,
      notification.title,
      notification.body,
      tz.TZDateTime.from(notification.utcTime, tz.UTC),
      _detailsForNotification(notification),
      // Exact alarm agar adzan tepat waktu meski device idle (Doze).
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: notification.prayer.name,
    );
  }

  /// Notifikasi yang masih menunggu (untuk debugging/verifikasi).
  Future<List<PendingNotificationRequest>> pending() =>
      _plugin.pendingNotificationRequests();
}
