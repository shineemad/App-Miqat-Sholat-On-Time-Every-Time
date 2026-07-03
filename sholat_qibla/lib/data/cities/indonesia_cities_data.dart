import 'city_model.dart';

/// Daftar lengkap kota-kota Indonesia beserta koordinat dan zona waktu.
///
/// Data ini digunakan untuk:
/// - Pilihan kota manual (tanpa izin GPS) saat onboarding / settings.
/// - Reverse geocoding offline: menemukan kota terdekat dari koordinat GPS.
///
/// Sumber koordinat: data geografis standar (WGS-84).
/// Zona waktu dibagi menjadi 3 wilayah Indonesia:
///   WIB  (UTC+7) → "Asia/Jakarta"
///   WITA (UTC+8) → "Asia/Makassar"
///   WIT  (UTC+9) → "Asia/Jayapura"

const List<CityModel> kIndonesiaCities = [
  // ── ACEH ──────────────────────────────────────────────────────────────────
  CityModel(
    id: 'banda_aceh',
    name: 'Banda Aceh',
    province: 'Aceh',
    latitude: 5.5483,
    longitude: 95.3238,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'lhokseumawe',
    name: 'Lhokseumawe',
    province: 'Aceh',
    latitude: 5.1801,
    longitude: 97.1500,
    timezone: 'Asia/Jakarta',
  ),

  // ── SUMATERA UTARA ────────────────────────────────────────────────────────
  CityModel(
    id: 'medan',
    name: 'Medan',
    province: 'Sumatera Utara',
    latitude: 3.5952,
    longitude: 98.6722,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'binjai',
    name: 'Binjai',
    province: 'Sumatera Utara',
    latitude: 3.6000,
    longitude: 98.4833,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'pematangsiantar',
    name: 'Pematangsiantar',
    province: 'Sumatera Utara',
    latitude: 2.9595,
    longitude: 99.0687,
    timezone: 'Asia/Jakarta',
  ),

  // ── SUMATERA BARAT ────────────────────────────────────────────────────────
  CityModel(
    id: 'padang',
    name: 'Padang',
    province: 'Sumatera Barat',
    latitude: -0.9492,
    longitude: 100.3543,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'bukittinggi',
    name: 'Bukittinggi',
    province: 'Sumatera Barat',
    latitude: -0.3078,
    longitude: 100.3681,
    timezone: 'Asia/Jakarta',
  ),

  // ── RIAU ──────────────────────────────────────────────────────────────────
  CityModel(
    id: 'pekanbaru',
    name: 'Pekanbaru',
    province: 'Riau',
    latitude: 0.5071,
    longitude: 101.4478,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'dumai',
    name: 'Dumai',
    province: 'Riau',
    latitude: 1.6667,
    longitude: 101.4500,
    timezone: 'Asia/Jakarta',
  ),

  // ── KEPULAUAN RIAU ────────────────────────────────────────────────────────
  CityModel(
    id: 'tanjungpinang',
    name: 'Tanjungpinang',
    province: 'Kepulauan Riau',
    latitude: 0.9192,
    longitude: 104.4460,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'batam',
    name: 'Batam',
    province: 'Kepulauan Riau',
    latitude: 1.0456,
    longitude: 104.0305,
    timezone: 'Asia/Jakarta',
  ),

  // ── JAMBI ─────────────────────────────────────────────────────────────────
  CityModel(
    id: 'jambi',
    name: 'Jambi',
    province: 'Jambi',
    latitude: -1.6101,
    longitude: 103.6131,
    timezone: 'Asia/Jakarta',
  ),

  // ── SUMATERA SELATAN ──────────────────────────────────────────────────────
  CityModel(
    id: 'palembang',
    name: 'Palembang',
    province: 'Sumatera Selatan',
    latitude: -2.9761,
    longitude: 104.7754,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'prabumulih',
    name: 'Prabumulih',
    province: 'Sumatera Selatan',
    latitude: -3.4333,
    longitude: 104.2333,
    timezone: 'Asia/Jakarta',
  ),

  // ── BANGKA BELITUNG ───────────────────────────────────────────────────────
  CityModel(
    id: 'pangkalpinang',
    name: 'Pangkalpinang',
    province: 'Bangka Belitung',
    latitude: -2.1316,
    longitude: 106.1169,
    timezone: 'Asia/Jakarta',
  ),

  // ── BENGKULU ──────────────────────────────────────────────────────────────
  CityModel(
    id: 'bengkulu',
    name: 'Bengkulu',
    province: 'Bengkulu',
    latitude: -3.7928,
    longitude: 102.2608,
    timezone: 'Asia/Jakarta',
  ),

  // ── LAMPUNG ───────────────────────────────────────────────────────────────
  CityModel(
    id: 'bandarlampung',
    name: 'Bandar Lampung',
    province: 'Lampung',
    latitude: -5.3971,
    longitude: 105.2668,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'metro',
    name: 'Metro',
    province: 'Lampung',
    latitude: -5.1167,
    longitude: 105.3000,
    timezone: 'Asia/Jakarta',
  ),

  // ── BANTEN ────────────────────────────────────────────────────────────────
  CityModel(
    id: 'serang',
    name: 'Serang',
    province: 'Banten',
    latitude: -6.1201,
    longitude: 106.1503,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'tangerang',
    name: 'Tangerang',
    province: 'Banten',
    latitude: -6.1783,
    longitude: 106.6319,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'tangerang_selatan',
    name: 'Tangerang Selatan',
    province: 'Banten',
    latitude: -6.2884,
    longitude: 106.7141,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'cilegon',
    name: 'Cilegon',
    province: 'Banten',
    latitude: -6.0028,
    longitude: 106.0055,
    timezone: 'Asia/Jakarta',
  ),

  // ── DKI JAKARTA ───────────────────────────────────────────────────────────
  CityModel(
    id: 'jakarta',
    name: 'Jakarta',
    province: 'DKI Jakarta',
    latitude: -6.2088,
    longitude: 106.8456,
    timezone: 'Asia/Jakarta',
  ),

  // ── JAWA BARAT ────────────────────────────────────────────────────────────
  CityModel(
    id: 'bandung',
    name: 'Bandung',
    province: 'Jawa Barat',
    latitude: -6.9175,
    longitude: 107.6191,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'bekasi',
    name: 'Bekasi',
    province: 'Jawa Barat',
    latitude: -6.2382,
    longitude: 106.9756,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'bogor',
    name: 'Bogor',
    province: 'Jawa Barat',
    latitude: -6.5971,
    longitude: 106.8060,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'depok',
    name: 'Depok',
    province: 'Jawa Barat',
    latitude: -6.4025,
    longitude: 106.7942,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'cirebon',
    name: 'Cirebon',
    province: 'Jawa Barat',
    latitude: -6.7320,
    longitude: 108.5523,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'tasikmalaya',
    name: 'Tasikmalaya',
    province: 'Jawa Barat',
    latitude: -7.3274,
    longitude: 108.2207,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'sukabumi',
    name: 'Sukabumi',
    province: 'Jawa Barat',
    latitude: -6.9200,
    longitude: 106.9300,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'karawang',
    name: 'Karawang',
    province: 'Jawa Barat',
    latitude: -6.3213,
    longitude: 107.3383,
    timezone: 'Asia/Jakarta',
  ),

  // ── JAWA TENGAH ───────────────────────────────────────────────────────────
  CityModel(
    id: 'semarang',
    name: 'Semarang',
    province: 'Jawa Tengah',
    latitude: -6.9934,
    longitude: 110.4203,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'solo',
    name: 'Solo',
    province: 'Jawa Tengah',
    latitude: -7.5755,
    longitude: 110.8243,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'magelang',
    name: 'Magelang',
    province: 'Jawa Tengah',
    latitude: -7.4710,
    longitude: 110.2176,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'salatiga',
    name: 'Salatiga',
    province: 'Jawa Tengah',
    latitude: -7.3305,
    longitude: 110.5082,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'kudus',
    name: 'Kudus',
    province: 'Jawa Tengah',
    latitude: -6.8049,
    longitude: 110.8488,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'tegal',
    name: 'Tegal',
    province: 'Jawa Tengah',
    latitude: -6.8797,
    longitude: 109.1256,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'pekalongan',
    name: 'Pekalongan',
    province: 'Jawa Tengah',
    latitude: -6.8875,
    longitude: 109.6751,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'purwokerto',
    name: 'Purwokerto',
    province: 'Jawa Tengah',
    latitude: -7.4207,
    longitude: 109.2384,
    timezone: 'Asia/Jakarta',
  ),

  // ── DI YOGYAKARTA ─────────────────────────────────────────────────────────
  CityModel(
    id: 'yogyakarta',
    name: 'Yogyakarta',
    province: 'DI Yogyakarta',
    latitude: -7.7956,
    longitude: 110.3695,
    timezone: 'Asia/Jakarta',
  ),

  // ── JAWA TIMUR ────────────────────────────────────────────────────────────
  CityModel(
    id: 'surabaya',
    name: 'Surabaya',
    province: 'Jawa Timur',
    latitude: -7.2575,
    longitude: 112.7521,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'malang',
    name: 'Malang',
    province: 'Jawa Timur',
    latitude: -7.9797,
    longitude: 112.6304,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'kediri',
    name: 'Kediri',
    province: 'Jawa Timur',
    latitude: -7.8480,
    longitude: 112.0180,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'madiun',
    name: 'Madiun',
    province: 'Jawa Timur',
    latitude: -7.6298,
    longitude: 111.5239,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'jember',
    name: 'Jember',
    province: 'Jawa Timur',
    latitude: -8.1845,
    longitude: 113.6681,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'batu',
    name: 'Batu',
    province: 'Jawa Timur',
    latitude: -7.8709,
    longitude: 112.5267,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'blitar',
    name: 'Blitar',
    province: 'Jawa Timur',
    latitude: -8.0957,
    longitude: 112.1609,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'mojokerto',
    name: 'Mojokerto',
    province: 'Jawa Timur',
    latitude: -7.4724,
    longitude: 112.4339,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'pasuruan',
    name: 'Pasuruan',
    province: 'Jawa Timur',
    latitude: -7.6456,
    longitude: 112.9078,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'probolinggo',
    name: 'Probolinggo',
    province: 'Jawa Timur',
    latitude: -7.7543,
    longitude: 113.2159,
    timezone: 'Asia/Jakarta',
  ),

  // ── BALI ──────────────────────────────────────────────────────────────────
  CityModel(
    id: 'denpasar',
    name: 'Denpasar',
    province: 'Bali',
    latitude: -8.6500,
    longitude: 115.2167,
    timezone: 'Asia/Makassar',
  ),

  // ── NUSA TENGGARA BARAT ───────────────────────────────────────────────────
  CityModel(
    id: 'mataram',
    name: 'Mataram',
    province: 'NTB',
    latitude: -8.5833,
    longitude: 116.1167,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'bima',
    name: 'Bima',
    province: 'NTB',
    latitude: -8.4667,
    longitude: 118.7167,
    timezone: 'Asia/Makassar',
  ),

  // ── NUSA TENGGARA TIMUR ───────────────────────────────────────────────────
  CityModel(
    id: 'kupang',
    name: 'Kupang',
    province: 'NTT',
    latitude: -10.1718,
    longitude: 123.6073,
    timezone: 'Asia/Makassar',
  ),

  // ── KALIMANTAN BARAT ──────────────────────────────────────────────────────
  CityModel(
    id: 'pontianak',
    name: 'Pontianak',
    province: 'Kalimantan Barat',
    latitude: -0.0263,
    longitude: 109.3425,
    timezone: 'Asia/Jakarta',
  ),
  CityModel(
    id: 'singkawang',
    name: 'Singkawang',
    province: 'Kalimantan Barat',
    latitude: 0.9000,
    longitude: 108.9750,
    timezone: 'Asia/Jakarta',
  ),

  // ── KALIMANTAN TENGAH ─────────────────────────────────────────────────────
  CityModel(
    id: 'palangkaraya',
    name: 'Palangkaraya',
    province: 'Kalimantan Tengah',
    latitude: -2.2136,
    longitude: 113.9108,
    timezone: 'Asia/Jakarta',
  ),

  // ── KALIMANTAN SELATAN ────────────────────────────────────────────────────
  CityModel(
    id: 'banjarmasin',
    name: 'Banjarmasin',
    province: 'Kalimantan Selatan',
    latitude: -3.3194,
    longitude: 114.5908,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'banjarbaru',
    name: 'Banjarbaru',
    province: 'Kalimantan Selatan',
    latitude: -3.4419,
    longitude: 114.8316,
    timezone: 'Asia/Makassar',
  ),

  // ── KALIMANTAN TIMUR ──────────────────────────────────────────────────────
  CityModel(
    id: 'samarinda',
    name: 'Samarinda',
    province: 'Kalimantan Timur',
    latitude: -0.4977,
    longitude: 117.1436,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'balikpapan',
    name: 'Balikpapan',
    province: 'Kalimantan Timur',
    latitude: -1.2654,
    longitude: 116.8312,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'bontang',
    name: 'Bontang',
    province: 'Kalimantan Timur',
    latitude: 0.1333,
    longitude: 117.5000,
    timezone: 'Asia/Makassar',
  ),

  // ── KALIMANTAN UTARA ──────────────────────────────────────────────────────
  CityModel(
    id: 'tarakan',
    name: 'Tarakan',
    province: 'Kalimantan Utara',
    latitude: 3.3011,
    longitude: 117.6350,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'nunukan',
    name: 'Nunukan',
    province: 'Kalimantan Utara',
    latitude: 4.1431,
    longitude: 117.6679,
    timezone: 'Asia/Makassar',
  ),

  // ── SULAWESI UTARA ────────────────────────────────────────────────────────
  CityModel(
    id: 'manado',
    name: 'Manado',
    province: 'Sulawesi Utara',
    latitude: 1.4748,
    longitude: 124.8421,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'bitung',
    name: 'Bitung',
    province: 'Sulawesi Utara',
    latitude: 1.4456,
    longitude: 125.1919,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'tomohon',
    name: 'Tomohon',
    province: 'Sulawesi Utara',
    latitude: 1.3177,
    longitude: 124.8279,
    timezone: 'Asia/Makassar',
  ),

  // ── GORONTALO ─────────────────────────────────────────────────────────────
  CityModel(
    id: 'gorontalo',
    name: 'Gorontalo',
    province: 'Gorontalo',
    latitude: 0.5435,
    longitude: 123.0568,
    timezone: 'Asia/Makassar',
  ),

  // ── SULAWESI TENGAH ───────────────────────────────────────────────────────
  CityModel(
    id: 'palu',
    name: 'Palu',
    province: 'Sulawesi Tengah',
    latitude: -0.9010,
    longitude: 119.8707,
    timezone: 'Asia/Makassar',
  ),

  // ── SULAWESI BARAT ────────────────────────────────────────────────────────
  CityModel(
    id: 'mamuju',
    name: 'Mamuju',
    province: 'Sulawesi Barat',
    latitude: -2.6667,
    longitude: 118.8833,
    timezone: 'Asia/Makassar',
  ),

  // ── SULAWESI SELATAN ──────────────────────────────────────────────────────
  CityModel(
    id: 'makassar',
    name: 'Makassar',
    province: 'Sulawesi Selatan',
    latitude: -5.1477,
    longitude: 119.4327,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'palopo',
    name: 'Palopo',
    province: 'Sulawesi Selatan',
    latitude: -2.9925,
    longitude: 120.1962,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'parepare',
    name: 'Parepare',
    province: 'Sulawesi Selatan',
    latitude: -4.0135,
    longitude: 119.6330,
    timezone: 'Asia/Makassar',
  ),

  // ── SULAWESI TENGGARA ─────────────────────────────────────────────────────
  CityModel(
    id: 'kendari',
    name: 'Kendari',
    province: 'Sulawesi Tenggara',
    latitude: -3.9985,
    longitude: 122.5130,
    timezone: 'Asia/Makassar',
  ),
  CityModel(
    id: 'baubau',
    name: 'Baubau',
    province: 'Sulawesi Tenggara',
    latitude: -5.4667,
    longitude: 122.6167,
    timezone: 'Asia/Makassar',
  ),

  // ── MALUKU ────────────────────────────────────────────────────────────────
  CityModel(
    id: 'ambon',
    name: 'Ambon',
    province: 'Maluku',
    latitude: -3.6552,
    longitude: 128.1908,
    timezone: 'Asia/Jayapura',
  ),
  CityModel(
    id: 'tual',
    name: 'Tual',
    province: 'Maluku',
    latitude: -5.6333,
    longitude: 132.7500,
    timezone: 'Asia/Jayapura',
  ),

  // ── MALUKU UTARA ──────────────────────────────────────────────────────────
  CityModel(
    id: 'ternate',
    name: 'Ternate',
    province: 'Maluku Utara',
    latitude: 0.7833,
    longitude: 127.3667,
    timezone: 'Asia/Jayapura',
  ),
  CityModel(
    id: 'tidore',
    name: 'Tidore Kepulauan',
    province: 'Maluku Utara',
    latitude: 0.6833,
    longitude: 127.4167,
    timezone: 'Asia/Jayapura',
  ),

  // ── PAPUA BARAT ───────────────────────────────────────────────────────────
  CityModel(
    id: 'manokwari',
    name: 'Manokwari',
    province: 'Papua Barat',
    latitude: -0.8615,
    longitude: 134.0622,
    timezone: 'Asia/Jayapura',
  ),
  CityModel(
    id: 'sorong',
    name: 'Sorong',
    province: 'Papua Barat',
    latitude: -0.8833,
    longitude: 131.2500,
    timezone: 'Asia/Jayapura',
  ),

  // ── PAPUA ─────────────────────────────────────────────────────────────────
  CityModel(
    id: 'jayapura',
    name: 'Jayapura',
    province: 'Papua',
    latitude: -2.5333,
    longitude: 140.7167,
    timezone: 'Asia/Jayapura',
  ),
  CityModel(
    id: 'merauke',
    name: 'Merauke',
    province: 'Papua',
    latitude: -8.4667,
    longitude: 140.3333,
    timezone: 'Asia/Jayapura',
  ),
  CityModel(
    id: 'timika',
    name: 'Timika',
    province: 'Papua',
    latitude: -4.5333,
    longitude: 136.8833,
    timezone: 'Asia/Jayapura',
  ),
];
