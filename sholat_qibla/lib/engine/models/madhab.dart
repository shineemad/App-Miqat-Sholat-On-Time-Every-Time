/// Madzhab untuk perhitungan waktu Ashar.
///
/// - [shafi]: bayangan = 1x tinggi benda (Syafi'i, Maliki, Hanbali).
/// - [hanafi]: bayangan = 2x tinggi benda.
enum Madhab {
  shafi(shadowFactor: 1),
  hanafi(shadowFactor: 2);

  const Madhab({required this.shadowFactor});

  /// Faktor panjang bayangan relatif terhadap tinggi benda.
  final int shadowFactor;

  static Madhab fromName(String name) => Madhab.values.firstWhere(
        (m) => m.name == name,
        orElse: () => Madhab.shafi,
      );
}
