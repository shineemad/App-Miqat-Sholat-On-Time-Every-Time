import 'lat_lng.dart';

/// Data kota untuk mode offline (tanpa GPS).
class City {
  const City({
    required this.id,
    required this.name,
    required this.province,
    required this.country,
    required this.location,
    required this.utcOffset,
    this.elevation = 0,
  });

  final String id;
  final String name;
  final String province;
  final String country;
  final LatLng location;

  /// Offset zona waktu terhadap UTC dalam jam (mis. WIB = 7.0).
  final double utcOffset;

  /// Ketinggian di atas permukaan laut dalam meter.
  final double elevation;

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json['id'] as String,
        name: json['name'] as String,
        province: json['province'] as String? ?? '',
        country: json['country'] as String? ?? 'Indonesia',
        location: LatLng(
          (json['lat'] as num).toDouble(),
          (json['lng'] as num).toDouble(),
        ),
        utcOffset: (json['utcOffset'] as num).toDouble(),
        elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'province': province,
        'country': country,
        'lat': location.latitude,
        'lng': location.longitude,
        'utcOffset': utcOffset,
        'elevation': elevation,
      };

  @override
  bool operator ==(Object other) => other is City && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'City($id, $name)';
}
