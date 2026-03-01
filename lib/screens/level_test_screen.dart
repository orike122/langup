import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/level_questions.dart';
import '../models/level.dart';
import '../providers/level_provider.dart';

class LevelTestScreen extends ConsumerStatefulWidget {
  const LevelTestScreen({super.key});

  @override
  ConsumerState<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends ConsumerState<LevelTestScreen> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedIndex;
  bool _answered = false;

  LevelQuestion get _current => levelQuestions[_currentIndex];

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedIndex = index;
      _answered = true;
      if (index == _current.correctIndex) _score++;
    });
  }

  Future<void> _next() async {
    if (_currentIndex < levelQuestions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = null;
        _answered = false;
      });
    } else {
      final level = scoreToLevel(_score);
      // Persist directly so splash can read it.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cefr_level', level.storageKey);
      if (!mounted) return;
      _showResultDialog(level);
    }
  }

  void _showResultDialog(CefrLevel level) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Your Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              level.displayName,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Score: $_score / ${levelQuestions.length}'),
            const SizedBox(height: 8),
            const Text(
              'Lena will now adapt to your level. Let\'s start talking!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed('/conversation');
            },
            child: const Text('Start Conversation'),
          ),
        ],
      ),
    );
  }

  Color? _optionColor(int index) {
    if (!_answered) return null;
    if (index == _current.correctIndex) return Colors.green.shade100;
    if (index == _selectedIndex) return Colors.red.shade100;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = (_currentIndex + 1) / levelQuestions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Level Test'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Text(
              'Question ${_currentIndex + 1} of ${levelQuestions.length}',
              style: TextStyle(color: colors.outline, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Text(
              _current.question,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            )
                .animate(key: ValueKey(_currentIndex))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: 24),
            ...List.generate(_current.options.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _OptionTile(
                  label: _current.options[i],
                  color: _optionColor(i),
                  isCorrect: _answered && i == _current.correctIndex,
                  isWrong: _answered &&
                      i == _selectedIndex &&
                      i != _current.correctIndex,
                  onTap: () => _selectAnswer(i),
                ),
              )
                  .animate(key: ValueKey('$_currentIndex-$i'))
                  .fadeIn(delay: (50 * i).ms, duration: 300.ms)
                  .slideX(begin: 0.05, end: 0);
            }),
            const Spacer(),
            if (_answered)
              FilledButton(
                onPressed: _next,
                child: Text(
                  _currentIndex < levelQuestions.length - 1
                      ? 'Next Question'
                      : 'See My Level',
                ),
              ).animate().fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final Color? color;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.color,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
              if (isCorrect)
                const Icon(Icons.check_circle, color: Colors.green)
              else if (isWrong)
                const Icon(Icons.cancel, color: Colors.red),
            ],
          ),
        ),
      ),
    );
  }
}
