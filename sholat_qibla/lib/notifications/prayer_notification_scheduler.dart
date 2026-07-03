import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'notification_models.dart';

// ── Channel IDs ────────────────────────────────────────────────────────────
const _chAdhan = 'prayer_adhan';
const _chVibration = 'prayer_vibration';
const _chSilent = 'prayer_silent';

// ── Notification ID layout ─────────────────────────────────────────────────
// Setiap sholat mendapat blok 10 ID:
//   base * 10 + 0 → notifikasi utama
//   base * 10 + 1 → pra-adzan
// PrayerName.index = 0..4, sehingga ID = 0..49
int _mainId(PrayerName p) => p.index * 10;
int _preAdhanId(PrayerName p) => p.index * 10 + 1;

/// Menjadwalkan dan membatalkan notifikasi waktu sholat lokal di perangkat.
///
/// Tidak memerlukan koneksi internet — semua notifikasi dijadwalkan via
/// API sistem OS (flutter_local_notifications) berdasarkan waktu dari
/// Prayer Engine. Tidak ada server push yang dilibatkan.
///
/// Panggil [initialize] sekali saat app startup sebelum metode lainnya.
///
/// Contoh alur pemakaian:
/// ```dart
/// final scheduler = PrayerNotificationScheduler();
/// await scheduler.initialize();
/// await scheduler.scheduleForDay(
///   entries: prayerTimes,
///   toggles: prefs.notificationToggles,
///   sounds: prefs.notificationSounds,
///   preAdhanMinutes: prefs.preAdhanMinutes,
///   respectDnd: prefs.respectDnd,
///   hideContent: prefs.hideNotificationContent,
/// );
/// ```
///
/// **Catatan Android Doze**: flutter_local_notifications menggunakan
/// `AndroidScheduleMode.exactAllowWhileIdle` agar alarm tetap berdering
/// di mode Doze. Untuk perangkat Android 12+, izin
/// `SCHEDULE_EXACT_ALARM` atau `USE_EXACT_ALARM` wajib ada di
/// AndroidManifest.xml.
class PrayerNotificationScheduler {
  final FlutterLocalNotificationsPlugin _plugin;

  /// Fungsi pengambil waktu saat ini. Default: [DateTime.now].
  /// Dapat diinjek saat testing agar test bersifat deterministik.
  final DateTime Function() _now;

  PrayerNotificationScheduler({
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? now,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _now = now ?? DateTime.now;

  // ── Inisialisasi ──────────────────────────────────────────────────────────

  /// Inisialisasi plugin dan database zona waktu.
  ///
  /// Harus dipanggil sekali di `main()` sebelum `runApp()`.
  Future<void> initialize({
    /// Callback saat pengguna mengetuk notifikasi (app sudah buka).
    void Function(NotificationResponse)? onNotificationTap,

    /// Callback saat pengguna mengetuk notifikasi dari background/terminated.
    void Function(NotificationResponse)? onBackgroundNotificationTap,
  }) async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onBackgroundNotificationTap,
    );

    await _createAndroidChannels();
  }

  // ── Permintaan izin ───────────────────────────────────────────────────────

  /// Meminta izin notifikasi dari pengguna (Android 13+ / iOS).
  ///
  /// Kembalikan true jika izin diberikan.
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }

    return false;
  }

  // ── Penjadwalan ───────────────────────────────────────────────────────────

  /// Jadwalkan notifikasi untuk satu hari penuh berdasarkan daftar waktu sholat.
  ///
  /// Metode ini:
  /// 1. Membatalkan semua notifikasi sholat yang sudah terjadwal sebelumnya.
  /// 2. Menjadwal ulang hanya untuk sholat yang [toggles]-nya aktif.
  /// 3. Menambahkan notifikasi pra-adzan jika [preAdhanMinutes] > 0.
  /// 4. Melewati waktu yang sudah lewat (di masa lalu).
  ///
  /// Parameter:
  /// - [entries]         : daftar waktu sholat dari Prayer Engine.
  /// - [toggles]         : map nama sholat → aktif/nonaktif.
  /// - [sounds]          : map nama sholat → suara ("adhan"/"vibration"/"silent").
  /// - [preAdhanMinutes] : menit pengingat sebelum adzan (0 = nonaktif).
  /// - [respectDnd]      : jika true, gunakan urgency MEDIUM agar DND tidak dilanggar.
  /// - [hideContent]     : jika true, sembunyikan detail di lock screen.
  /// - [locationTz]      : timezone kota pengguna (default "Asia/Jakarta").
  ///
  /// Mengembalikan daftar notifikasi yang berhasil dijadwalkan.
  Future<List<ScheduledNotification>> scheduleForDay({
    required List<PrayerTimeEntry> entries,
    required Map<String, bool> toggles,
    required Map<String, String> sounds,
    int preAdhanMinutes = 0,
    bool respectDnd = true,
    bool hideContent = false,
    String locationTz = 'Asia/Jakarta',
  }) async {
    await cancelAll();

    final scheduled = <ScheduledNotification>[];
    final now = _now();
    final location = tz.getLocation(locationTz);

    for (final entry in entries) {
      final isEnabled = toggles[entry.prayer.displayName] ?? true;
      if (!isEnabled) continue;

      final soundStr = sounds[entry.prayer.displayName] ?? 'adhan';
      final sound = _parseSound(soundStr);

      // ── Notifikasi utama ─────────────────────────────────────────────────
      if (entry.scheduledAt.isAfter(now)) {
        final tzTime = tz.TZDateTime.from(entry.scheduledAt, location);
        await _scheduleOne(
          id: _mainId(entry.prayer),
          prayer: entry.prayer,
          tzTime: tzTime,
          sound: sound,
          isPreAdhan: false,
          respectDnd: respectDnd,
          hideContent: hideContent,
        );
        scheduled.add(ScheduledNotification(
          id: _mainId(entry.prayer),
          prayer: entry.prayer,
          scheduledAt: entry.scheduledAt,
          sound: sound,
        ));
      }

      // ── Notifikasi pra-adzan ─────────────────────────────────────────────
      if (preAdhanMinutes > 0) {
        final preTime =
            entry.scheduledAt.subtract(Duration(minutes: preAdhanMinutes));
        if (preTime.isAfter(now)) {
          final tzPre = tz.TZDateTime.from(preTime, location);
          await _scheduleOne(
            id: _preAdhanId(entry.prayer),
            prayer: entry.prayer,
            tzTime: tzPre,
            sound: NotificationSound.vibration,
            isPreAdhan: true,
            respectDnd: respectDnd,
            hideContent: hideContent,
          );
          scheduled.add(ScheduledNotification(
            id: _preAdhanId(entry.prayer),
            prayer: entry.prayer,
            scheduledAt: preTime,
            sound: NotificationSound.vibration,
            isPreAdhan: true,
          ));
        }
      }
    }

    return scheduled;
  }

  // ── Pembatalan ────────────────────────────────────────────────────────────

  /// Batalkan semua notifikasi sholat yang sudah terjadwal.
  Future<void> cancelAll() => _plugin.cancelAll();

  /// Batalkan notifikasi satu sholat tertentu (utama dan pra-adzan).
  Future<void> cancelPrayer(PrayerName prayer) async {
    await _plugin.cancel(_mainId(prayer));
    await _plugin.cancel(_preAdhanId(prayer));
  }

  // ── Status ────────────────────────────────────────────────────────────────

  /// Daftar semua notifikasi yang saat ini terjadwal (untuk debugging / Settings UI).
  Future<List<PendingNotificationRequest>> getPendingNotifications() =>
      _plugin.pendingNotificationRequests();

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _scheduleOne({
    required int id,
    required PrayerName prayer,
    required tz.TZDateTime tzTime,
    required NotificationSound sound,
    required bool isPreAdhan,
    required bool respectDnd,
    required bool hideContent,
  }) async {
    final details = _buildDetails(
      prayer: prayer,
      sound: sound,
      isPreAdhan: isPreAdhan,
      respectDnd: respectDnd,
      hideContent: hideContent,
    );

    final title = isPreAdhan
        ? 'Persiapan ${prayer.displayName}'
        : 'Waktu ${prayer.displayName}';
    final body = hideContent
        ? '' // Sembunyikan isi notifikasi di lock screen
        : isPreAdhan
            ? 'Waktu ${prayer.displayName} sebentar lagi.'
            : 'Sudah masuk waktu ${prayer.displayName}.';

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  NotificationDetails _buildDetails({
    required PrayerName prayer,
    required NotificationSound sound,
    required bool isPreAdhan,
    required bool respectDnd,
    required bool hideContent,
  }) {
    final channelId = _channelId(sound);
    final channelName = _channelName(sound);

    final importance = respectDnd ? Importance.defaultImportance : Importance.high;
    final priority = respectDnd ? Priority.defaultPriority : Priority.high;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: importance,
      priority: priority,
      enableVibration: sound == NotificationSound.vibration ||
          sound == NotificationSound.adhan,
      playSound: sound == NotificationSound.adhan,
      visibility: hideContent
          ? NotificationVisibility.secret
          : NotificationVisibility.public,
      ticker: prayer.displayName,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: !hideContent,
      presentSound: sound == NotificationSound.adhan,
      presentBadge: false,
    );

    return NotificationDetails(android: androidDetails, iOS: iosDetails);
  }

  Future<void> _createAndroidChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(const AndroidNotificationChannel(
      _chAdhan,
      'Adzan',
      description: 'Notifikasi waktu sholat dengan suara adzan.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    ));

    await android.createNotificationChannel(const AndroidNotificationChannel(
      _chVibration,
      'Getaran',
      description: 'Notifikasi waktu sholat hanya dengan getaran.',
      importance: Importance.defaultImportance,
      playSound: false,
      enableVibration: true,
    ));

    await android.createNotificationChannel(const AndroidNotificationChannel(
      _chSilent,
      'Senyap',
      description: 'Notifikasi waktu sholat tanpa suara dan getaran.',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    ));
  }

  static String _channelId(NotificationSound sound) {
    switch (sound) {
      case NotificationSound.adhan:
        return _chAdhan;
      case NotificationSound.vibration:
        return _chVibration;
      case NotificationSound.silent:
        return _chSilent;
    }
  }

  static String _channelName(NotificationSound sound) {
    switch (sound) {
      case NotificationSound.adhan:
        return 'Adzan';
      case NotificationSound.vibration:
        return 'Getaran';
      case NotificationSound.silent:
        return 'Senyap';
    }
  }

  static NotificationSound _parseSound(String raw) {
    switch (raw) {
      case 'vibration':
        return NotificationSound.vibration;
      case 'silent':
        return NotificationSound.silent;
      default:
        return NotificationSound.adhan;
    }
  }
}
