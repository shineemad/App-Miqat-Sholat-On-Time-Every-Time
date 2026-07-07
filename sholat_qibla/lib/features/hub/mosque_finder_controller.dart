import '../../data/location/location_resolver.dart';
import '../../data/location/location_service.dart';
import '../../data/preferences/preferences_repository.dart';
import '../../engine/models/lat_lng.dart';
import 'mosque_finder_service.dart';

/// Hasil pencarian masjid + konteks lokasi yang dipakai.
class MosqueSearchResult {
  const MosqueSearchResult({
    required this.mosques,
    required this.center,
    required this.locationLabel,
    required this.usedGps,
  });

  final List<Mosque> mosques;
  final LatLng center;

  /// Label lokasi untuk ditampilkan (nama kota / "Lokasi GPS").
  final String locationLabel;
  final bool usedGps;
}

/// Controller Pencari Masjid: resolusi lokasi berlapis (GPS presisi ->
/// kota terpilih) lalu query sumber data masjid.
class MosqueFinderController {
  MosqueFinderController({
    required MosqueDataSource dataSource,
    required LocationService locationService,
    required LocationResolver resolver,
    required PreferencesRepository preferences,
  })  : _dataSource = dataSource,
        _location = locationService,
        _resolver = resolver,
        _preferences = preferences;

  final MosqueDataSource _dataSource;
  final LocationService _location;
  final LocationResolver _resolver;
  final PreferencesRepository _preferences;

  /// Radius pencarian default (meter).
  static const int defaultRadiusMeters = 5000;

  /// Mencari masjid terdekat dari posisi pengguna.
  ///
  /// GPS dipakai bila diizinkan (presisi jalan); jika tidak, memakai
  /// koordinat kota terpilih. Melempar [MosqueLookupException] bila
  /// pencarian gagal (mis. offline).
  Future<MosqueSearchResult> search(
      {int radiusMeters = defaultRadiusMeters}) async {
    LatLng? center;
    String label = '';
    var usedGps = false;

    if (_preferences.getUseGps()) {
      final result = await _location.getCurrentLocation();
      if (result is LocationSuccess) {
        center = result.position;
        label = 'Lokasi GPS';
        usedGps = true;
      }
    }
    if (center == null) {
      final resolved = await _resolver.resolve();
      center = resolved.city.location;
      label = resolved.city.name;
    }

    final mosques =
        await _dataSource.findNearby(center, radiusMeters: radiusMeters);
    return MosqueSearchResult(
      mosques: mosques,
      center: center,
      locationLabel: label,
      usedGps: usedGps,
    );
  }
}
