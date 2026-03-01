import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/level_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    // Ensure SharedPreferences is initialised and injected before routing.
    final prefs = await SharedPreferences.getInstance();

    // Minimum splash display time.
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Override the provider with the real prefs instance.
    // We use a ProviderContainer override at app startup instead;
    // here we just read the stored level directly.
    final levelStr = prefs.getString('cefr_level');
    if (levelStr == null) {
      Navigator.of(context).pushReplacementNamed('/level-test');
    } else {
      Navigator.of(context).pushReplacementNamed('/conversation');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.primary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.language_rounded, size: 80, color: colors.onPrimary),
              const SizedBox(height: 16),
              Text(
                'Langup',
                style: TextStyle(
                  color: colors.onPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Deutsch lernen',
                style: TextStyle(color: colors.onPrimary.withOpacity(0.8)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
