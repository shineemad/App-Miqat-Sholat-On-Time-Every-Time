/// Konstanta perhitungan astronomi & default aplikasi.
abstract final class CalculationConstants {
  /// Sudut standar matahari di bawah horizon saat terbit/terbenam
  /// (refraksi atmosfer 0.567° + semi-diameter matahari 0.266°).
  static const double sunriseSunsetAngle = 0.833;

  /// Koefisien koreksi ketinggian pengamat: 0.0347 * sqrt(elevasi meter).
  static const double elevationCoefficient = 0.0347;

  /// Koordinat Ka'bah, Makkah.
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Default aplikasi.
  static const String defaultMethodName = 'kemenag';
  static const String defaultMadhabName = 'shafi';
  static const String defaultCityId = 'jakarta';
}
