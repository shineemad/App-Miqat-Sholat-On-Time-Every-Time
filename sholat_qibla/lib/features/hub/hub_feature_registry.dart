/// Definisi satu fitur di layar Hub.
///
/// Fitur yang belum diimplementasikan ditandai [available] = false
/// (stub/interface untuk pengembangan mendatang), sehingga UI dapat
/// menampilkannya sebagai "Segera Hadir".
class HubFeature {
  const HubFeature({
    required this.id,
    required this.title,
    required this.description,
    required this.route,
    required this.available,
  });

  final String id;
  final String title;
  final String description;

  /// Nama rute navigasi (lihat AppRouter).
  final String route;

  /// true = siap dipakai; false = stub "Segera Hadir".
  final bool available;
}

/// Registry seluruh fitur Hub (aktif maupun stub masa depan).
///
/// Menjadi satu sumber kebenaran untuk daftar menu Hub sekaligus titik
/// ekstensi bagi fitur baru (Pencari Masjid, Ramadhan Mode, dll).
abstract final class HubFeatureRegistry {
  static const List<HubFeature> features = [
    HubFeature(
      id: 'tasbih',
      title: 'Tasbih Digital',
      description: 'Penghitung dzikir dengan target & riwayat putaran',
      route: '/hub/tasbih',
      available: true,
    ),
    HubFeature(
      id: 'quran',
      title: 'Al-Quran',
      description: 'Baca, cari ayat, dan tandai bacaan terakhir',
      route: '/quran',
      available: true,
    ),
    HubFeature(
      id: 'hijri',
      title: 'Kalender Hijriah',
      description: 'Konversi tanggal Masehi ke Hijriah',
      route: '/hub/hijri',
      available: true,
    ),
    HubFeature(
      id: 'mosque_finder',
      title: 'Pencari Masjid',
      description: 'Temukan masjid terdekat di sekitar Anda',
      route: '/hub/mosque-finder',
      available: true,
    ),
    HubFeature(
      id: 'ramadhan_mode',
      title: 'Mode Ramadhan',
      description: 'Jadwal imsak, sahur, dan buka puasa',
      route: '/hub/ramadhan',
      available: true,
    ),
  ];

  /// Fitur yang sudah dapat digunakan.
  static List<HubFeature> get available =>
      features.where((f) => f.available).toList();

  /// Fitur stub (belum tersedia).
  static List<HubFeature> get comingSoon =>
      features.where((f) => !f.available).toList();

  static HubFeature? byId(String id) {
    for (final feature in features) {
      if (feature.id == id) return feature;
    }
    return null;
  }
}
