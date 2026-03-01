import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/level_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/level_test_screen.dart';
import 'screens/conversation_screen.dart';

class LangupApp extends StatelessWidget {
  const LangupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Langup',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const SplashScreen(),
      routes: {
        '/level-test': (_) => const LevelTestScreen(),
        '/conversation': (_) => const ConversationScreen(),
      },
    );
  }

  ThemeData _buildTheme() {
    const seedColor = Color(0xFF2E7D32); // forest green
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    );
  }
}

/// Routes after splash resolves level state.
class RootRouter extends ConsumerWidget {
  const RootRouter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final level = ref.watch(levelProvider);
    if (level == null) {
      return const LevelTestScreen();
    }
    return const ConversationScreen();
  }
}
