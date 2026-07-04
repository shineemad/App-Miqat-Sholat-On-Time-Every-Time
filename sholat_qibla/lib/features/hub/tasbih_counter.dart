import 'package:shared_preferences/shared_preferences.dart';

/// State satu sesi tasbih.
class TasbihState {
  const TasbihState({
    required this.count,
    required this.target,
    required this.rounds,
  });

  final int count;

  /// Target hitungan per putaran (mis. 33).
  final int target;

  /// Jumlah putaran yang telah selesai.
  final int rounds;

  /// Progres putaran saat ini (0.0 - 1.0).
  double get progress => target == 0 ? 0 : (count % target) / target;

  /// Apakah hitungan tepat menyentuh kelipatan target (>0).
  bool get isRoundComplete => count > 0 && target > 0 && count % target == 0;

  TasbihState copyWith({int? count, int? target, int? rounds}) => TasbihState(
        count: count ?? this.count,
        target: target ?? this.target,
        rounds: rounds ?? this.rounds,
      );

  @override
  bool operator ==(Object other) =>
      other is TasbihState &&
      other.count == count &&
      other.target == target &&
      other.rounds == rounds;

  @override
  int get hashCode => Object.hash(count, target, rounds);
}

/// Penghitung tasbih dengan penyimpanan sesi & target (offline).
///
/// Logika murni + persistensi opsional lewat SharedPreferences, sehingga
/// dapat diuji tanpa Flutter binding (bila `prefs` di-mock).
class TasbihCounter {
  TasbihCounter(this._prefs);

  static const int defaultTarget = 33;

  static const _kCount = 'tasbih_count';
  static const _kTarget = 'tasbih_target';
  static const _kRounds = 'tasbih_rounds';

  final SharedPreferences _prefs;

  static Future<TasbihCounter> create({SharedPreferences? prefs}) async =>
      TasbihCounter(prefs ?? await SharedPreferences.getInstance());

  /// Memuat sesi tersimpan (atau default bila belum ada).
  TasbihState load() => TasbihState(
        count: _prefs.getInt(_kCount) ?? 0,
        target: _prefs.getInt(_kTarget) ?? defaultTarget,
        rounds: _prefs.getInt(_kRounds) ?? 0,
      );

  /// Menambah satu hitungan; menaikkan putaran saat menyentuh target.
  Future<TasbihState> increment() async {
    final current = load();
    final nextCount = current.count + 1;
    final crossedTarget =
        current.target > 0 && nextCount % current.target == 0;
    final next = current.copyWith(
      count: nextCount,
      rounds: crossedTarget ? current.rounds + 1 : current.rounds,
    );
    await _save(next);
    return next;
  }

  /// Mengurangi satu hitungan (tidak di bawah nol).
  Future<TasbihState> decrement() async {
    final current = load();
    if (current.count == 0) return current;
    final next = current.copyWith(count: current.count - 1);
    await _save(next);
    return next;
  }

  /// Mengatur target per putaran (mis. 33 / 99 / 100). Minimal 1.
  Future<TasbihState> setTarget(int target) async {
    final safe = target < 1 ? 1 : target;
    final next = load().copyWith(target: safe);
    await _save(next);
    return next;
  }

  /// Mereset hitungan & putaran ke nol (target dipertahankan).
  Future<TasbihState> reset() async {
    final next = load().copyWith(count: 0, rounds: 0);
    await _save(next);
    return next;
  }

  Future<void> _save(TasbihState state) async {
    await _prefs.setInt(_kCount, state.count);
    await _prefs.setInt(_kTarget, state.target);
    await _prefs.setInt(_kRounds, state.rounds);
  }
}
