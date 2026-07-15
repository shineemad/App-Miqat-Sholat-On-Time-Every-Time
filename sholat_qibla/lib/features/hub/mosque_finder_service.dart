import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../engine/models/lat_lng.dart';

/// true saat dikompilasi untuk web (pengganti kIsWeb tanpa dependensi
/// Flutter, agar service tetap pure Dart & dapat diuji via `dart run`).
const bool _isWeb = bool.fromEnvironment('dart.library.js_interop');

/// Satu masjid hasil pencarian.
class Mosque {
  const Mosque({
    required this.name,
    required this.location,
    required this.distanceKm,
  });

  final String name;
  final LatLng location;

  /// Jarak great-circle dari lokasi pengguna (km).
  final double distanceKm;
}

/// Sumber data masjid terdekat — abstraksi agar mudah di-mock pada test.
abstract interface class MosqueDataSource {
  /// Mencari masjid dalam radius [radiusMeters] dari [center].
  ///
  /// Melempar [MosqueLookupException] bila jaringan/server gagal.
  Future<List<Mosque>> findNearby(LatLng center, {int radiusMeters});
}

/// Kegagalan pencarian masjid (offline, timeout, atau server error).
class MosqueLookupException implements Exception {
  const MosqueLookupException(this.message);
  final String message;

  @override
  String toString() => 'MosqueLookupException: $message';
}

/// Implementasi [MosqueDataSource] dengan Overpass API (OpenStreetMap).
///
/// Memakai package:http agar berjalan di semua platform (fetch di web,
/// dart:io di Android/iOS/desktop). Overpass mengizinkan CORS
/// (Access-Control-Allow-Origin: *) sehingga web juga didukung.
///
/// Gratis & tanpa API key. Fitur ini satu-satunya yang online — dipanggil
/// hanya saat pengguna membuka Pencari Masjid (opt-in), tanpa mengirim
/// data apa pun selain koordinat area pencarian.
class OverpassMosqueDataSource implements MosqueDataSource {
  OverpassMosqueDataSource({http.Client? client})
      : _client = client ?? http.Client();

  /// Endpoint utama + mirror (dicoba berurutan bila gagal/timeout).
  static const List<String> endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
  ];

  /// Batas waktu per endpoint.
  static const Duration requestTimeout = Duration(seconds: 15);

  final http.Client _client;

  @override
  Future<List<Mosque>> findNearby(LatLng center,
      {int radiusMeters = 5000}) async {
    final query = '[out:json][timeout:15];'
        '(node["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$radiusMeters,${center.latitude},${center.longitude});'
        'way["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$radiusMeters,${center.latitude},${center.longitude}););'
        'out center 40;';

    Object? lastError;
    for (final endpoint in endpoints) {
      try {
        final response = await _client
            .post(
              Uri.parse(endpoint),
              headers: {
                'Content-Type':
                    'application/x-www-form-urlencoded; charset=utf-8',
                // Kebijakan OSM: User-Agent deskriptif (tanpa ini 406).
                // Di web, browser mengirim UA-nya sendiri (header ini
                // terlarang untuk di-set dari halaman).
                if (!_isWeb)
                  'User-Agent':
                      'MU-Qibla-PrayerApp/1.0 (offline-first prayer app)',
              },
              body: 'data=${Uri.encodeQueryComponent(query)}',
            )
            .timeout(requestTimeout);

        if (response.statusCode != 200) {
          lastError = MosqueLookupException('Server ${response.statusCode}');
          continue; // coba mirror berikutnya
        }
        return parseOverpass(utf8.decode(response.bodyBytes), center);
      } on TimeoutException {
        lastError = const MosqueLookupException('Waktu koneksi habis');
      } on MosqueLookupException catch (e) {
        lastError = e;
      } catch (e) {
        lastError = MosqueLookupException('Tidak dapat terhubung: $e');
      }
    }
    throw lastError is MosqueLookupException
        ? lastError
        : MosqueLookupException('$lastError');
  }

  /// Parse respons JSON Overpass menjadi daftar [Mosque] terurut jarak.
  ///
  /// Dipisah statis agar dapat diuji tanpa jaringan.
  static List<Mosque> parseOverpass(String jsonBody, LatLng center) {
    final root = jsonDecode(jsonBody) as Map<String, dynamic>;
    final elements = (root['elements'] as List?) ?? const [];

    final mosques = <Mosque>[];
    for (final raw in elements) {
      final el = raw as Map<String, dynamic>;
      // Node punya lat/lon langsung; way memakai "center".
      final lat = (el['lat'] ?? el['center']?['lat']) as num?;
      final lon = (el['lon'] ?? el['center']?['lon']) as num?;
      if (lat == null || lon == null) continue;

      final tags = (el['tags'] as Map<String, dynamic>?) ?? const {};
      final name = (tags['name'] as String?)?.trim();
      final location = LatLng(lat.toDouble(), lon.toDouble());
      mosques.add(Mosque(
        name: name == null || name.isEmpty ? 'Masjid (tanpa nama)' : name,
        location: location,
        distanceKm: center.distanceTo(location),
      ));
    }

    mosques.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return mosques;
  }
}
