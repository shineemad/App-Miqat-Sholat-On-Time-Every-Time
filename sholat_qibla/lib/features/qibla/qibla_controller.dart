import '../../data/cities/city_repository.dart';
import '../../data/location/location_resolver.dart';
import '../../data/location/location_service.dart';
import '../../data/preferences/preferences_repository.dart';
import '../../engine/models/city.dart';
import '../../engine/models/lat_lng.dart';
import 'qibla_calculator.dart';
import 'qibla_compass_service.dart';

export '../../data/location/location_resolver.dart' show LocationSource;

/// Informasi kiblat statis untuk lokasi terpilih (independen dari sensor).
class QiblaInfo {
  const QiblaInfo({
    required this.city,
    required this.source,
    required this.bearing,
    required this.distanceKm,
  });

  final City city;
  final LocationSource source;

  /// Sudut kiblat terhadap utara sejati, derajat [0, 360).
  final double bearing;

  /// Jarak great-circle ke Ka'bah dalam kilometer.
  final double distanceKm;

  LatLng get location => city.location;
}

/// Controller layar Kiblat: menyelesaikan lokasi, menghitung bearing &
/// jarak ke Ka'bah, serta menyediakan stream [QiblaState] dari kompas.
class QiblaController {
  QiblaController({
    required LocationService locationService,
    required CityRepository cityRepository,
    required PreferencesRepository preferences,
    required CompassSource compassSource,
    QiblaCompassService? compassService,
  })  : _resolver = LocationResolver(
          locationService: locationService,
          cityRepository: cityRepository,
          preferences: preferences,
        ),
        _compassSource = compassSource,
        _compass = compassService ??
            QiblaCompassService(source: compassSource);

  final LocationResolver _resolver;
  final CompassSource _compassSource;
  final QiblaCompassService _compass;

  /// Resolusi lokasi + info kiblat statis (bearing & jarak).
  Future<QiblaInfo> loadInfo() async {
    final resolved = await _resolver.resolve();
    final loc = resolved.city.location;
    return QiblaInfo(
      city: resolved.city,
      source: resolved.source,
      bearing: QiblaCalculator.qiblaBearing(loc),
      distanceKm: QiblaCalculator.distanceToKaabaKm(loc),
    );
  }

  /// Apakah perangkat memiliki sensor kompas (magnetometer).
  Future<bool> hasCompass() => _compassSource.hasCompass();

  /// Stream status kiblat live untuk [location].
  Stream<QiblaState?> watch(LatLng location) => _compass.watch(location);

  /// Reset penghalusan heading (mis. saat layar dibuka ulang).
  void reset() => _compass.reset();
}
