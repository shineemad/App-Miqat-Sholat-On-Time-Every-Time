import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sholat_qibla/notifications/notification_models.dart';
import 'package:sholat_qibla/notifications/prayer_notification_scheduler.dart';
import 'package:timezone/data/latest.dart' as tz_data;

import 'prayer_notification_scheduler_test.mocks.dart';

@GenerateMocks([FlutterLocalNotificationsPlugin])
void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late PrayerNotificationScheduler scheduler;

  /// Jam patokan: hari ini jam 08:00 WIB
  final now = DateTime(2026, 7, 3, 8, 0);

  /// Entri waktu sholat lengkap satu hari (di masa depan dari [now])
  List<PrayerTimeEntry> buildEntries({DateTime? referenceNow}) {
    final base = referenceNow ?? now;
    return [
      PrayerTimeEntry(
        prayer: PrayerName.subuh,
        scheduledAt: DateTime(base.year, base.month, base.day, 4, 30),
      ),
      PrayerTimeEntry(
        prayer: PrayerName.dzuhur,
        scheduledAt: DateTime(base.year, base.month, base.day, 11, 55),
      ),
      PrayerTimeEntry(
        prayer: PrayerName.ashar,
        scheduledAt: DateTime(base.year, base.month, base.day, 15, 15),
      ),
      PrayerTimeEntry(
        prayer: PrayerName.maghrib,
        scheduledAt: DateTime(base.year, base.month, base.day, 17, 52),
      ),
      PrayerTimeEntry(
        prayer: PrayerName.isya,
        scheduledAt: DateTime(base.year, base.month, base.day, 19, 5),
      ),
    ];
  }

  setUp(() {
    // Inisialisasi timezone database sebelum setiap test.
    tz_data.initializeTimeZones();

    mockPlugin = MockFlutterLocalNotificationsPlugin();

    // Stub: cancelAll tidak melempar exception
    when(mockPlugin.cancelAll()).thenAnswer((_) async {});

    // Stub: zonedSchedule tidak melempar exception
    when(
      mockPlugin.zonedSchedule(
        any,
        any,
        any,
        any,
        any,
        androidScheduleMode: anyNamed('androidScheduleMode'),
        uiLocalNotificationDateInterpretation:
            anyNamed('uiLocalNotificationDateInterpretation'),
      ),
    ).thenAnswer((_) async {});

    scheduler = PrayerNotificationScheduler(
      plugin: mockPlugin,
      now: () => now, // Jam tetap 08:00 agar test deterministik
    );
  });

  // ── scheduleForDay — semua notifikasi aktif ────────────────────────────────
  group('scheduleForDay — semua notifikasi aktif', () {
    test('cancelAll dipanggil sekali sebelum penjadwalan', () async {
      final entries = buildEntries();
      final toggles = {
        'Subuh': true,
        'Dzuhur': true,
        'Ashar': true,
        'Maghrib': true,
        'Isya': true,
      };
      final sounds = {
        'Subuh': 'adhan',
        'Dzuhur': 'silent',
        'Ashar': 'silent',
        'Maghrib': 'adhan',
        'Isya': 'adhan',
      };

      await scheduler.scheduleForDay(
        entries: entries,
        toggles: toggles,
        sounds: sounds,
        locationTz: 'Asia/Jakarta',
      );

      verify(mockPlugin.cancelAll()).called(1);
    });

    test('5 notifikasi utama dijadwalkan untuk 5 sholat aktif (di masa depan)', () async {
      // Subuh sudah lewat jam 08:00, jadi hanya 4 sholat yang dijadwalkan
      final entries = buildEntries(); // Subuh 04:30 sudah lewat jam now=08:00
      final toggles = {
        'Subuh': true,
        'Dzuhur': true,
        'Ashar': true,
        'Maghrib': true,
        'Isya': true,
      };
      final sounds = {for (final p in ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']) p: 'adhan'};

      final scheduled = await scheduler.scheduleForDay(
        entries: entries,
        toggles: toggles,
        sounds: sounds,
        locationTz: 'Asia/Jakarta',
      );

      // Subuh 04:30 sudah lewat pukul 08:00 → tidak dijadwalkan
      expect(scheduled.where((s) => !s.isPreAdhan).length, equals(4));
    });
  });

  // ── scheduleForDay — toggle per-sholat ────────────────────────────────────
  group('scheduleForDay — toggle per-sholat', () {
    test('sholat yang dinonaktifkan tidak dijadwalkan', () async {
      final entries = buildEntries();
      final toggles = {
        'Subuh': true,
        'Dzuhur': false, // nonaktif
        'Ashar': true,
        'Maghrib': false, // nonaktif
        'Isya': true,
      };
      final sounds = {for (final p in ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']) p: 'adhan'};

      final scheduled = await scheduler.scheduleForDay(
        entries: entries,
        toggles: toggles,
        sounds: sounds,
        locationTz: 'Asia/Jakarta',
      );

      final mainScheduled = scheduled.where((s) => !s.isPreAdhan);
      expect(mainScheduled.any((s) => s.prayer == PrayerName.dzuhur), isFalse);
      expect(mainScheduled.any((s) => s.prayer == PrayerName.maghrib), isFalse);
    });

    test('jika semua dinonaktifkan, tidak ada notifikasi terjadwal', () async {
      final entries = buildEntries();
      final toggles = {for (final p in ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']) p: false};
      final sounds = {for (final p in toggles.keys) p: 'adhan'};

      final scheduled = await scheduler.scheduleForDay(
        entries: entries,
        toggles: toggles,
        sounds: sounds,
        locationTz: 'Asia/Jakarta',
      );

      expect(scheduled, isEmpty);
    });
  });

  // ── scheduleForDay — pra-adzan ────────────────────────────────────────────
  group('scheduleForDay — pra-adzan', () {
    test('pra-adzan dijadwalkan jika preAdhanMinutes > 0', () async {
      final entries = buildEntries();
      final toggles = {for (final p in ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']) p: true};
      final sounds = {for (final p in toggles.keys) p: 'adhan'};

      final scheduled = await scheduler.scheduleForDay(
        entries: entries,
        toggles: toggles,
        sounds: sounds,
        preAdhanMinutes: 10,
        locationTz: 'Asia/Jakarta',
      );

      final preAdhanNotifs = scheduled.where((s) => s.isPreAdhan);
      expect(preAdhanNotifs, isNotEmpty);
    });

    test('pra-adzan TIDAK dijadwalkan jika preAdhanMinutes = 0 (default)', () async {
      final entries = buildEntries();
      final toggles = {for (final p in ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']) p: true};
      final sounds = {for (final p in toggles.keys) p: 'adhan'};

      final scheduled = await scheduler.scheduleForDay(
        entries: entries,
        toggles: toggles,
        sounds: sounds,
        preAdhanMinutes: 0,
        locationTz: 'Asia/Jakarta',
      );

      expect(scheduled.any((s) => s.isPreAdhan), isFalse);
    });

    test('pra-adzan menggunakan suara vibration', () async {
      final entries = buildEntries();
      final toggles = {for (final p in ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']) p: true};
      final sounds = {for (final p in toggles.keys) p: 'adhan'};

      final scheduled = await scheduler.scheduleForDay(
        entries: entries,
        toggles: toggles,
        sounds: sounds,
        preAdhanMinutes: 5,
        locationTz: 'Asia/Jakarta',
      );

      for (final notif in scheduled.where((s) => s.isPreAdhan)) {
        expect(notif.sound, equals(NotificationSound.vibration));
      }
    });

    test('waktu pra-adzan tepat [preAdhanMinutes] menit sebelum waktu sholat', () async {
      final entries = buildEntries();
      final dzuhurEntry = entries.firstWhere((e) => e.prayer == PrayerName.dzuhur);
      final toggles = {for (final p in ['Subuh', 'Dzuhur', 'Ashar', 'Maghrib', 'Isya']) p: true};
      final sounds = {for (final p in toggles.keys) p: 'adhan'};

      final scheduled = await scheduler.scheduleForDay(
        entries: entries,
        toggles: toggles,
        sounds: sounds,
        preAdhanMinutes: 15,
        locationTz: 'Asia/Jakarta',
      );

      final dzuhurPre = scheduled.firstWhere(
        (s) => s.prayer == PrayerName.dzuhur && s.isPreAdhan,
        orElse: () => throw StateError('pra-adzan Dzuhur tidak ditemukan'),
      );

      final expectedTime =
          dzuhurEntry.scheduledAt.subtract(const Duration(minutes: 15));
      expect(dzuhurPre.scheduledAt, equals(expectedTime));
    });
  });

  // ── cancelAll ─────────────────────────────────────────────────────────────
  group('cancelAll', () {
    test('meneruskan panggilan ke plugin', () async {
      await scheduler.cancelAll();
      verify(mockPlugin.cancelAll()).called(1);
    });
  });

  // ── PrayerTimeEntry ───────────────────────────────────────────────────────
  group('PrayerTimeEntry', () {
    test('toString informatif', () {
      final entry = PrayerTimeEntry(
        prayer: PrayerName.subuh,
        scheduledAt: DateTime(2026, 7, 3, 4, 30),
      );
      expect(entry.toString(), contains('Subuh'));
    });
  });

  // ── PrayerName ────────────────────────────────────────────────────────────
  group('PrayerName.displayName', () {
    test('semua enum memiliki displayName yang sesuai', () {
      expect(PrayerName.subuh.displayName, equals('Subuh'));
      expect(PrayerName.dzuhur.displayName, equals('Dzuhur'));
      expect(PrayerName.ashar.displayName, equals('Ashar'));
      expect(PrayerName.maghrib.displayName, equals('Maghrib'));
      expect(PrayerName.isya.displayName, equals('Isya'));
    });
  });

  // ── ScheduledNotification ─────────────────────────────────────────────────
  group('ScheduledNotification', () {
    test('toString mencantumkan id, nama sholat, dan waktu', () {
      final notif = ScheduledNotification(
        id: 10,
        prayer: PrayerName.dzuhur,
        scheduledAt: DateTime(2026, 7, 3, 12, 0),
        sound: NotificationSound.adhan,
      );
      expect(notif.toString(), contains('10'));
      expect(notif.toString(), contains('Dzuhur'));
    });

    test('isPreAdhan default false', () {
      final notif = ScheduledNotification(
        id: 0,
        prayer: PrayerName.subuh,
        scheduledAt: DateTime(2026, 7, 3, 4, 30),
        sound: NotificationSound.adhan,
      );
      expect(notif.isPreAdhan, isFalse);
    });
  });
}
