import 'dart:convert';
import 'dart:io';

import '../../engine/models/lat_lng.dart';

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
  /// Melempar [MosqueLookupException] bila jaringan/served gagal.
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
/// Gratis & tanpa API key. Fitur ini satu-satunya yang online — dipanggil
/// hanya saat pengguna membuka Pencari Masjid (opt-in), tanpa mengirim
/// data apa pun selain koordinat area pencarian.
class OverpassMosqueDataSource implements MosqueDataSource {
  OverpassMosqueDataSource({HttpClient? client})
      : _client = (client ?? HttpClient())
          ..connectionTimeout = const Duration(seconds: 10)
          // Kebijakan Overpass/OSM: sertakan User-Agent deskriptif
          // (tanpa ini server membalas 406 Not Acceptable).
          ..userAgent = 'Miqat-PrayerApp/1.0 (offline-first prayer app)';

  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  final HttpClient _client;

  @override
  Future<List<Mosque>> findNearby(LatLng center,
      {int radiusMeters = 5000}) async {
    final query = '[out:json][timeout:15];'
        '(node["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$radiusMeters,${center.latitude},${center.longitude});'
        'way["amenity"="place_of_worship"]["religion"="muslim"]'
        '(around:$radiusMeters,${center.latitude},${center.longitude}););'
        'out center 40;';

    try {
      final request = await _client.postUrl(Uri.parse(_endpoint));
      request.headers.contentType =
          ContentType('application', 'x-www-form-urlencoded', charset: 'utf-8');
      request.write('data=${Uri.encodeQueryComponent(query)}');
      final response = await request.close();
      if (response.statusCode != 200) {
        throw MosqueLookupException('Server ${response.statusCode}');
      }
      final body = await response.transform(utf8.decoder).join();
      return parseOverpass(body, center);
    } on MosqueLookupException {
      rethrow;
    } catch (e) {
      throw MosqueLookupException('Tidak dapat terhubung: $e');
    }
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
