/// Hasil kalkulasi arah dan jarak ke Ka'bah.
class QiblaResult {
  /// Sudut arah kiblat diukur dari Utara (0°) searah jarum jam.
  /// Rentang: [0, 360).
  final double bearingDegrees;

  /// Jarak ke Ka'bah dalam kilometer (great circle distance).
  final double distanceKm;

  const QiblaResult({
    required this.bearingDegrees,
    required this.distanceKm,
  });

  /// Nilai bearing dibulatkan untuk ditampilkan di UI.
  String get bearingDisplay => '${bearingDegrees.round()}°';

  /// Jarak dibulatkan ke km terdekat.
  String get distanceDisplay => '${distanceKm.round()} km';

  @override
  String toString() =>
      'QiblaResult(bearing: ${bearingDegrees.toStringAsFixed(1)}°, '
      'distance: ${distanceKm.toStringAsFixed(0)} km)';
}
