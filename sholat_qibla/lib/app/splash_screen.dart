import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../data/preferences/preferences_repository.dart';
import 'app_router.dart';
import 'injection.dart';

/// Layar pembuka (splash) beranimasi saat aplikasi dibuka.
///
/// Menampilkan logo Miqat dengan animasi masuk, lalu berpindah otomatis
/// ke Onboarding (bila first-run) atau Beranda.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
  );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
  ));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _controller.addStatusListener(_onDone);
  }

  void _onDone(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    // Jeda singkat agar logo sempat terbaca sebelum berpindah.
    Future.delayed(const Duration(milliseconds: 550), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    final onboardingDone = sl<PreferencesRepository>().isOnboardingDone();
    Navigator.of(context).pushReplacementNamed(
      AppRouter.initialRoute(onboardingDone: onboardingDone),
    );
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_onDone);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo beranimasi (scale + fade).
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    border: AppShapes.hardBorder,
                    borderRadius: AppShapes.card,
                    boxShadow: AppShapes.hardShadow,
                  ),
                  child: const Icon(Icons.mosque,
                      size: 56, color: AppColors.onPrimary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nama + tagline (fade + slide masuk setelah logo).
            FadeTransition(
              opacity: _textFade,
              child: SlideTransition(
                position: _textSlide,
                child: Column(
                  children: [
                    Text('Miqat',
                        style: AppTypography.textTheme.displaySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Sholat On Time, Every Time',
                      style: AppTypography.textTheme.bodyLarge!
                          .copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Indikator loading kecil.
            FadeTransition(
              opacity: _textFade,
              child: const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
