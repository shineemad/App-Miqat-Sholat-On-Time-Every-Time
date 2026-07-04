import 'dart:convert';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../../engine/models/city.dart';
import '../../engine/models/lat_lng.dart';

/// Repository database kota offline (dimuat dari asset JSON).
///
/// Menyediakan pencarian nama (geocoding lokal) dan pencarian kota
/// terdekat dari koordinat (reverse geocoding lokal).
class CityRepository {
  CityRepository({AssetBundle? bundle, String? assetPath})
      : _bundle = bundle ?? rootBundle,
        _assetPath = assetPath ?? defaultAssetPath;

  static const String defaultAssetPath = 'assets/data/cities_id.json';

  final AssetBundle _bundle;
  final String _assetPath;

  List<City>? _cache;

  /// Memuat seluruh kota (hasil di-cache di memori).
  Future<List<City>> getAllCities() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = (json['cities'] as List)
        .cast<Map<String, dynamic>>()
        .map(City.fromJson)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _cache = List.unmodifiable(list);
    return _cache!;
  }

  /// Mencari kota berdasarkan id, atau `null` jika tidak ada.
  Future<City?> getById(String id) async {
    final cities = await getAllCities();
    for (final city in cities) {
      if (city.id == id) return city;
    }
    return null;
  }

  /// Geocoding lokal: cari kota yang namanya/provinsinya memuat [query]
  /// (case-insensitive).
  Future<List<City>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAllCities();
    final cities = await getAllCities();
    return cities
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.province.toLowerCase().contains(q))
        .toList();
  }

  /// Reverse geocoding lokal: kota terdekat dari [position].
  ///
  /// Mengembalikan `null` jika database kosong atau jarak melebihi
  /// [maxDistanceKm] (default tanpa batas).
  Future<City?> findNearest(LatLng position, {double? maxDistanceKm}) async {
    final cities = await getAllCities();
    City? nearest;
    var best = double.infinity;
    for (final city in cities) {
      final d = position.distanceTo(city.location);
      if (d < best) {
        best = d;
        nearest = city;
      }
    }
    if (maxDistanceKm != null && best > maxDistanceKm) return null;
    return nearest;
  }

  /// Membersihkan cache (dipakai saat testing / update data).
  void clearCache() => _cache = null;
}
