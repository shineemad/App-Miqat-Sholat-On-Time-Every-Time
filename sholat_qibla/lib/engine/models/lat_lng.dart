import 'dart:math' as math;

/// Koordinat geografis (latitude, longitude) dalam derajat desimal.
class LatLng {
  const LatLng(this.latitude, this.longitude)
      : assert(latitude >= -90 && latitude <= 90,
            'Latitude harus di antara -90 dan 90'),
        assert(longitude >= -180 && longitude <= 180,
            'Longitude harus di antara -180 dan 180');

  final double latitude;
  final double longitude;

  static const double _earthRadiusKm = 6371.0;

  /// Jarak great-circle (Haversine) ke [other] dalam kilometer.
  double distanceTo(LatLng other) {
    final dLat = _degToRad(other.latitude - latitude);
    final dLng = _degToRad(other.longitude - longitude);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(latitude)) *
            math.cos(_degToRad(other.latitude)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return _earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * math.pi / 180.0;

  Map<String, dynamic> toJson() => {
        'lat': latitude,
        'lng': longitude,
      };

  factory LatLng.fromJson(Map<String, dynamic> json) => LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      );

  @override
  bool operator ==(Object other) =>
      other is LatLng &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
