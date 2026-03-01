import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/message.dart';
import '../models/correction.dart';
import 'correction_chip.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final void Function(String word)? onWordTap;

  const ChatBubble({super.key, required this.message, this.onWordTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    return Padding(
      padding: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isUser ? 48 : 8,
        right: isUser ? 8 : 48,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _Bubble(message: message, onWordTap: onWordTap),
          if (message.corrections.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: message.corrections
                    .map((c) => CorrectionChip(correction: c))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Message message;
  final void Function(String word)? onWordTap;

  const _Bubble({required this.message, this.onWordTap});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final colors = Theme.of(context).colorScheme;

    final bg = isUser ? colors.primary : colors.surfaceVariant;
    final fg = isUser ? colors.onPrimary : colors.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isUser ? 18 : 4),
          bottomRight: Radius.circular(isUser ? 4 : 18),
        ),
      ),
      child: message.isLoading
          ? _LoadingDots(color: fg)
          : isUser
              ? Text(message.text ?? '', style: TextStyle(color: fg))
              : _TappableText(
                  text: message.text ?? '',
                  color: fg,
                  wordDefinitions: {
                    for (final wd in message.wordDefinitions)
                      wd.word.toLowerCase(): wd,
                  },
                  onWordTap: onWordTap,
                ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}

/// Wraps each word so assistant words can be tapped for definitions.
class _TappableText extends StatelessWidget {
  final String text;
  final Color color;
  final Map<String, WordDefinition> wordDefinitions;
  final void Function(String word)? onWordTap;

  const _TappableText({
    required this.text,
    required this.color,
    required this.wordDefinitions,
    this.onWordTap,
  });

  static final _punctuationRe = RegExp(r'[^\w\säöüÄÖÜß]');

  String _stripPunctuation(String w) => w.replaceAll(_punctuationRe, '');

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    return Wrap(
      spacing: 3,
      runSpacing: 2,
      children: words.map((rawWord) {
        final key = _stripPunctuation(rawWord).toLowerCase();
        final hasDef = wordDefinitions.containsKey(key);
        return GestureDetector(
          onTap: onWordTap != null ? () => onWordTap!(key) : null,
          child: Text(
            '$rawWord ',
            style: TextStyle(
              color: color,
              decoration:
                  hasDef ? TextDecoration.underline : TextDecoration.none,
              decorationColor: color.withOpacity(0.5),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  final Color color;
  const _LoadingDots({required this.color});

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final opacity =
                (0.3 + 0.7 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2))
                    .clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
