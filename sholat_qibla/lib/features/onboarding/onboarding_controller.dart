import '../../data/preferences/preferences_repository.dart';
import '../../engine/models/calculation_method.dart';
import '../../engine/models/madhab.dart';

/// Langkah-langkah onboarding.
enum OnboardingStep { welcome, location, method, notifications, done }

/// Controller alur onboarding pertama kali.
///
/// Mengelola perpindahan langkah dan menyimpan pilihan awal pengguna
/// (kota, metode kalkulasi, madzhab) melalui [PreferencesRepository].
class OnboardingController {
  OnboardingController(this._preferences);

  final PreferencesRepository _preferences;

  OnboardingStep _step = OnboardingStep.welcome;
  OnboardingStep get currentStep => _step;

  bool get isFirstRun => !_preferences.isOnboardingDone();

  static const List<OnboardingStep> _flow = [
    OnboardingStep.welcome,
    OnboardingStep.location,
    OnboardingStep.method,
    OnboardingStep.notifications,
    OnboardingStep.done,
  ];

  /// Maju ke langkah berikutnya; mengembalikan langkah baru.
  OnboardingStep next() {
    final index = _flow.indexOf(_step);
    if (index < _flow.length - 1) {
      _step = _flow[index + 1];
    }
    return _step;
  }

  /// Mundur ke langkah sebelumnya; mengembalikan langkah baru.
  OnboardingStep previous() {
    final index = _flow.indexOf(_step);
    if (index > 0) {
      _step = _flow[index - 1];
    }
    return _step;
  }

  Future<void> chooseCity(String cityId) async {
    await _preferences.setSelectedCityId(cityId);
    await _preferences.setUseGps(false);
  }

  Future<void> enableGps() => _preferences.setUseGps(true);

  Future<void> chooseMethod(CalculationMethod method) =>
      _preferences.setCalculationMethod(method);

  Future<void> chooseMadhab(Madhab madhab) =>
      _preferences.setMadhab(madhab);

  /// Menyelesaikan onboarding dan menandainya selesai (permanen).
  Future<void> complete() async {
    _step = OnboardingStep.done;
    await _preferences.setOnboardingDone();
  }
}
