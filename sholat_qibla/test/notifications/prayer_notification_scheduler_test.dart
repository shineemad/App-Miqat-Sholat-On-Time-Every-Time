import 'package:flutter_test/flutter_test.dart';
import 'package:sholat_qibla/engine/models/calculation_method.dart';
import 'package:sholat_qibla/engine/models/lat_lng.dart';
import 'package:sholat_qibla/engine/models/madhab.dart';
import 'package:sholat_qibla/engine/models/prayer_times.dart';
import 'package:sholat_qibla/notifications/models/notification_settings.dart';
import 'package:sholat_qibla/notifications/prayer_notification_scheduler.dart';

class _FakeGateway implements NotificationGateway {
  final List<ScheduledPrayerNotification> scheduled = [];
  int cancelAllCount = 0;

  @override
  Future<void> cancelAll() async {
    cancelAllCount++;
    scheduled.clear();
  }

  @override
  Future<void> schedule(ScheduledPrayerNotification notification) async {
    scheduled.add(notification);
  }
}

void main() {
  const jakarta = LatLng(-6.2088, 106.8456);
  const utcOffset = 7.0;

  // Tengah malam WIB 3 Juli 2026 = 2 Juli 17:00 UTC.
  final midnightWibUtc = DateTime.utc(2026, 7, 2, 17, 0);

  PrayerNotificationScheduler makeScheduler(_FakeGateway gateway,
          {DateTime? now}) =>
      PrayerNotificationScheduler(
        gateway: gateway,
        clock: () => now ?? midnightWibUtc,
      );

  List<ScheduledPrayerNotification> build(
    PrayerNotificationScheduler scheduler, {
    NotificationSettings settings =
        const NotificationSettings(preAdhanEnabled: false),
    Map<Prayer, int> offsets = const {},
    int days = 3,
  }) =>
      scheduler.buildSchedule(
        location: jakarta,
        utcOffset: utcOffset,
        method: CalculationMethod.kemenag,
        madhab: Madhab.shafi,
        settings: settings,
        offsets: offsets,
        days: days,
      );

  group('PrayerNotificationScheduler - buildSchedule', () {
    test('menjadwalkan 5 waktu x N hari dari tengah malam', () {
      final schedule = build(makeScheduler(_FakeGateway()), days: 3);
      expect(schedule.length, 15);
    });

    test('melewati waktu yang sudah lampau hari ini', () {
      // Jam 12:30 WIB: subuh & dzuhur sudah lewat (dzuhur ~11:44),
      // tersisa ashar, maghrib, isya hari ini + 5 besok = 8 (days: 2).
      final noonWib = DateTime.utc(2026, 7, 3, 5, 30);
      final schedule =
          build(makeScheduler(_FakeGateway(), now: noonWib), days: 2);
      expect(schedule.length, 8);
      expect(schedule.first.prayer, Prayer.asr);
      expect(schedule.first.utcTime.isAfter(noonWib), isTrue);
    });

    test('semua waktu terjadwal di masa depan (UTC)', () {
      final schedule = build(makeScheduler(_FakeGateway()));
      for (final n in schedule) {
        expect(n.utcTime.isAfter(midnightWibUtc), isTrue);
      }
    });

    test('konversi wall clock -> UTC benar (WIB = UTC+7)', () {
      final schedule = build(makeScheduler(_FakeGateway()), days: 1);
      for (final n in schedule) {
        final diff = n.localTime.difference(
            DateTime(n.utcTime.year, n.utcTime.month, n.utcTime.day,
                n.utcTime.hour, n.utcTime.minute, n.utcTime.second));
        expect(diff.inMinutes, 7 * 60, reason: '${n.prayer}');
      }
    });

    test('sholat nonaktif tidak dijadwalkan', () {
      const settings = NotificationSettings(
        enabledPrayers: {Prayer.fajr, Prayer.maghrib},
        preAdhanEnabled: false,
      );
      final schedule =
          build(makeScheduler(_FakeGateway()), settings: settings, days: 2);
      expect(schedule.length, 4);
      expect(
        schedule.map((n) => n.prayer).toSet(),
        {Prayer.fajr, Prayer.maghrib},
      );
    });

    test('sunrise tidak pernah dijadwalkan', () {
      final schedule = build(makeScheduler(_FakeGateway()), days: 3);
      expect(schedule.any((n) => n.prayer == Prayer.sunrise), isFalse);
    });

    test('mode notifikasi diteruskan ke setiap jadwal', () {
      const settings = NotificationSettings(mode: AdhanMode.vibrate);
      final schedule =
          build(makeScheduler(_FakeGateway()), settings: settings, days: 1);
      expect(schedule.every((n) => n.mode == AdhanMode.vibrate), isTrue);
    });

    test('offset menit diterapkan', () {
      final base = build(makeScheduler(_FakeGateway()), days: 1);
      final shifted = build(
        makeScheduler(_FakeGateway()),
        offsets: {Prayer.fajr: 3},
        days: 1,
      );
      final baseFajr = base.firstWhere((n) => n.prayer == Prayer.fajr);
      final shiftedFajr = shifted.firstWhere((n) => n.prayer == Prayer.fajr);
      expect(
        shiftedFajr.localTime.difference(baseFajr.localTime).inMinutes,
        3,
      );
    });

    test('ID deterministik, unik, dan stabil antar pemanggilan', () {
      final a = build(makeScheduler(_FakeGateway()), days: 3);
      final b = build(makeScheduler(_FakeGateway()), days: 3);
      expect(a.map((n) => n.id).toSet().length, a.length);
      expect(a.map((n) => n.id).toList(), b.map((n) => n.id).toList());
    });

    test('notificationId muat dalam int32 (batas Android)', () {
      final id = PrayerNotificationScheduler.notificationId(
          DateTime(2099, 12, 31), Prayer.isha);
      expect(id, lessThan(2147483647));
      expect(id, 20991231 * 10 + Prayer.isha.index);
    });

    test('judul & isi berbahasa Indonesia sesuai sholat', () {
      final schedule = build(makeScheduler(_FakeGateway()), days: 1);
      final fajr = schedule.firstWhere((n) => n.prayer == Prayer.fajr);
      expect(fajr.title, contains('Subuh'));
      expect(fajr.body, contains('Subuh'));
    });
  });

  group('PrayerNotificationScheduler - rescheduleAll (auto-reschedule)', () {
    test('membatalkan semua lalu menjadwalkan ulang tanpa duplikat', () async {
      final gateway = _FakeGateway();
      final scheduler = makeScheduler(gateway);

      await scheduler.rescheduleAll(
        location: jakarta,
        utcOffset: utcOffset,
        method: CalculationMethod.kemenag,
        madhab: Madhab.shafi,
        settings: const NotificationSettings(preAdhanEnabled: false),
      );
      expect(gateway.cancelAllCount, 1);
      expect(gateway.scheduled.length, 15);

      // Reschedule kedua (mis. dipicu background fetch): tetap 15, tidak dobel.
      await scheduler.rescheduleAll(
        location: jakarta,
        utcOffset: utcOffset,
        method: CalculationMethod.kemenag,
        madhab: Madhab.shafi,
        settings: const NotificationSettings(preAdhanEnabled: false),
      );
      expect(gateway.cancelAllCount, 2);
      expect(gateway.scheduled.length, 15);
      expect(gateway.scheduled.map((n) => n.id).toSet().length, 15);
    });
  });

  group('PrayerNotificationScheduler - pengingat pra-adzan', () {
    test('menjadwalkan pengingat + adzan (2x jumlah) saat aktif', () {
      const settings = NotificationSettings(preAdhanMinutes: 10);
      final schedule = build(makeScheduler(_FakeGateway()),
          settings: settings, days: 1);
      // 5 adzan + 5 pengingat.
      expect(schedule.length, 10);
      expect(
        schedule.where((n) => n.kind == NotificationKind.reminder).length,
        5,
      );
    });

    test('waktu pengingat = waktu adzan - jeda menit', () {
      const settings = NotificationSettings(preAdhanMinutes: 10);
      final schedule = build(makeScheduler(_FakeGateway()),
          settings: settings, days: 1);
      final fajrAdhan = schedule.firstWhere(
          (n) => n.prayer == Prayer.fajr && n.kind == NotificationKind.adhan);
      final fajrReminder = schedule.firstWhere((n) =>
          n.prayer == Prayer.fajr && n.kind == NotificationKind.reminder);
      expect(
        fajrAdhan.utcTime.difference(fajrReminder.utcTime).inMinutes,
        10,
      );
    });

    test('jeda kustom (15 menit) diterapkan', () {
      const settings = NotificationSettings(preAdhanMinutes: 15);
      final schedule = build(makeScheduler(_FakeGateway()),
          settings: settings, days: 1);
      final adhan = schedule.firstWhere(
          (n) => n.prayer == Prayer.dhuhr && n.kind == NotificationKind.adhan);
      final reminder = schedule.firstWhere((n) =>
          n.prayer == Prayer.dhuhr && n.kind == NotificationKind.reminder);
      expect(adhan.localTime.difference(reminder.localTime).inMinutes, 15);
    });

    test('ID pengingat unik & berbeda dari adzan', () {
      const settings = NotificationSettings(preAdhanMinutes: 10);
      final schedule = build(makeScheduler(_FakeGateway()),
          settings: settings, days: 3);
      final ids = schedule.map((n) => n.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'semua ID unik');
      // ID pengingat & adzan tidak bertabrakan.
      final reminderIds = schedule
          .where((n) => n.kind == NotificationKind.reminder)
          .map((n) => n.id)
          .toSet();
      final adhanIds = schedule
          .where((n) => n.kind == NotificationKind.adhan)
          .map((n) => n.id)
          .toSet();
      expect(reminderIds.intersection(adhanIds), isEmpty);
    });

    test('pengingat nonaktif => hanya adzan', () {
      const settings = NotificationSettings(preAdhanEnabled: false);
      final schedule = build(makeScheduler(_FakeGateway()),
          settings: settings, days: 1);
      expect(schedule.every((n) => n.kind == NotificationKind.adhan), isTrue);
      expect(schedule.length, 5);
    });
  });
}
