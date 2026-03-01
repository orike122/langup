import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:record/record.dart';
import '../models/level.dart';
import '../providers/conversation_provider.dart';
import '../providers/level_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/word_definition_modal.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final level = ref.read(levelProvider) ?? CefrLevel.b1;
    ref.read(conversationProvider.notifier).setLevel(level);

    final hasPerm = await ref
        .read(conversationProvider.notifier)
        .audioService
        .hasMicPermission();
    if (!hasPerm && mounted) {
      final granted = await ref
          .read(conversationProvider.notifier)
          .audioService
          .requestMicPermission();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required to record audio.'),
          ),
        );
      }
    }

    // Check Android TTS voice.
    final tts = ref.read(conversationProvider.notifier).ttsService;
    await tts.init();
    if (tts.germanVoiceMissing && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'German TTS voice not installed. Go to Settings → Language & Input → Text-to-speech to install.',
          ),
          duration: Duration(seconds: 6),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _onMicPressed() async {
    final notifier = ref.read(conversationProvider.notifier);
    final status = ref.read(conversationProvider).status;

    if (status == ConversationStatus.idle) {
      await notifier.startRecording();
    } else if (status == ConversationStatus.recording) {
      await notifier.stopRecordingAndProcess();
    }
  }

  void _onWordTap(String word, BuildContext context) {
    WordDefinitionModal.show(
      context,
      word: word,
      lookupWord: (w) => ref.read(conversationProvider.notifier).lookupWord(w),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(conversationProvider);
    final level = ref.watch(levelProvider) ?? CefrLevel.b1;

    // Scroll when messages change.
    ref.listen(conversationProvider.select((s) => s.messages.length), (_, __) {
      _scrollToBottom();
    });

    // Show errors.
    ref.listen(conversationProvider.select((s) => s.error), (_, error) {
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () =>
                  ref.read(conversationProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lena — German Tutor'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(level.displayName),
              avatar: const Icon(Icons.school_outlined, size: 16),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'reset') {
                ref.read(levelProvider.notifier).clearLevel();
                Navigator.of(context).pushReplacementNamed('/level-test');
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Retake Level Test'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list.
          Expanded(
            child: state.messages.isEmpty
                ? _EmptyState(level: level)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: state.messages.length,
                    itemBuilder: (ctx, i) {
                      final msg = state.messages[i];
                      return ChatBubble(
                        message: msg,
                        onWordTap: msg.role == MessageRole.assistant
                            ? (word) => _onWordTap(word, ctx)
                            : null,
                      );
                    },
                  ),
          ),

          // Bottom input area.
          _BottomBar(
            status: state.status,
            onMicPressed: _onMicPressed,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final CefrLevel level;
  const _EmptyState({required this.level});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_none_rounded, size: 64, color: colors.outline),
          const SizedBox(height: 16),
          Text(
            'Tap the microphone to start\nspeaking with Lena',
            textAlign: TextAlign.center,
            style: TextStyle(color: colors.outline, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Level: ${level.displayName}',
            style: TextStyle(color: colors.primary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _BottomBar extends StatelessWidget {
  final ConversationStatus status;
  final VoidCallback onMicPressed;

  const _BottomBar({required this.status, required this.onMicPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isRecording = status == ConversationStatus.recording;
    final isProcessing = status == ConversationStatus.processing;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isProcessing)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Processing…',
                  style: TextStyle(color: colors.outline, fontSize: 13),
                ),
              ),
            if (isRecording)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Recording… tap to stop',
                  style: TextStyle(color: colors.error, fontSize: 13),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fadeIn(duration: 600.ms)
                    .then()
                    .fadeOut(duration: 600.ms),
              ),
            GestureDetector(
              onTap: isProcessing ? null : onMicPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isProcessing
                      ? colors.outline
                      : isRecording
                          ? colors.error
                          : colors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? colors.error : colors.primary)
                          .withOpacity(0.35),
                      blurRadius: isRecording ? 20 : 8,
                      spreadRadius: isRecording ? 4 : 0,
                    ),
                  ],
                ),
                child: isProcessing
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
