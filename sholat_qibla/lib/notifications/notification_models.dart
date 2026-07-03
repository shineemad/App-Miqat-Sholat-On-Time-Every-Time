/// Nama-nama sholat fardu harian.
enum PrayerName {
  subuh,
  dzuhur,
  ashar,
  maghrib,
  isya;

  /// Label yang ditampilkan di UI (Bahasa Indonesia).
  String get displayName {
    switch (this) {
      case PrayerName.subuh:
        return 'Subuh';
      case PrayerName.dzuhur:
        return 'Dzuhur';
      case PrayerName.ashar:
        return 'Ashar';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isya:
        return 'Isya';
    }
  }
}

/// Pilihan suara notifikasi per-sholat.
enum NotificationSound {
  /// Membunyikan adzan (file audio bawaan app).
  adhan,

  /// Hanya getaran, tanpa suara.
  vibration,

  /// Tanpa suara dan tanpa getaran (notifikasi senyap).
  silent,
}

/// Satu entri waktu sholat yang siap dijadwalkan sebagai notifikasi.
///
/// Objek ini dihasilkan oleh Prayer Engine lalu diterima oleh
/// [PrayerNotificationScheduler] untuk penjadwalan.
class PrayerTimeEntry {
  final PrayerName prayer;

  /// Waktu sholat yang tepat (sudah ditambah koreksi menit dari preferences).
  final DateTime scheduledAt;

  const PrayerTimeEntry({
    required this.prayer,
    required this.scheduledAt,
  });

  @override
  String toString() =>
      'PrayerTimeEntry(${prayer.displayName}, $scheduledAt)';
}

/// Notifikasi yang berhasil dijadwalkan.
/// Digunakan untuk logging dan debugging.
class ScheduledNotification {
  final int id;
  final PrayerName prayer;
  final DateTime scheduledAt;
  final NotificationSound sound;

  /// True jika ini adalah pengingat pra-adzan (bukan notifikasi waktu sholat).
  final bool isPreAdhan;

  const ScheduledNotification({
    required this.id,
    required this.prayer,
    required this.scheduledAt,
    required this.sound,
    this.isPreAdhan = false,
  });

  @override
  String toString() => 'ScheduledNotification('
      'id=$id, '
      '${isPreAdhan ? "pra-adzan " : ""}${prayer.displayName}, '
      '$scheduledAt, '
      '${sound.name})';
}
