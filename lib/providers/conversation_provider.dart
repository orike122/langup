import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/correction.dart';
import '../models/message.dart';
import '../models/level.dart';
import '../services/audio_service.dart';
import '../services/openai_service.dart';
import '../services/tts_service.dart';

enum ConversationStatus { idle, recording, processing }

class ConversationState {
  final List<Message> messages;
  final ConversationStatus status;
  final String? error;
  final Map<String, WordDefinition> wordCache;

  const ConversationState({
    this.messages = const [],
    this.status = ConversationStatus.idle,
    this.error,
    this.wordCache = const {},
  });

  ConversationState copyWith({
    List<Message>? messages,
    ConversationStatus? status,
    String? error,
    bool clearError = false,
    Map<String, WordDefinition>? wordCache,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      error: clearError ? null : error ?? this.error,
      wordCache: wordCache ?? this.wordCache,
    );
  }
}

final conversationProvider =
    StateNotifierProvider<ConversationNotifier, ConversationState>((ref) {
  return ConversationNotifier(
    audioService: AudioService(),
    openAiService: OpenAiService(),
    ttsService: TtsService(),
  );
});

class ConversationNotifier extends StateNotifier<ConversationState> {
  final AudioService audioService;
  final OpenAiService openAiService;
  final TtsService ttsService;

  CefrLevel _level = CefrLevel.b1;

  ConversationNotifier({
    required this.audioService,
    required this.openAiService,
    required this.ttsService,
  }) : super(const ConversationState());

  void setLevel(CefrLevel level) {
    _level = level;
  }

  Future<void> startRecording() async {
    if (state.status != ConversationStatus.idle) return;
    await ttsService.stop();
    await audioService.startRecording();
    state = state.copyWith(status: ConversationStatus.recording, clearError: true);
  }

  Future<void> stopRecordingAndProcess() async {
    if (state.status != ConversationStatus.recording) return;

    state = state.copyWith(status: ConversationStatus.processing);

    String? userMsgId;
    String? assistantMsgId;

    try {
      // 1. Stop recording and get audio file.
      final audioFile = await audioService.stopRecording();
      if (audioFile == null) throw Exception('Recording failed or was empty');

      // 2. Add user loading bubble.
      userMsgId = _uid();
      _addMessage(Message(
        id: userMsgId,
        role: MessageRole.user,
        isLoading: true,
      ));

      // 3. Transcribe.
      final transcription = await openAiService.transcribeAudio(audioFile);

      // 4. Update user bubble with text.
      _updateMessage(userMsgId, (m) => m.copyWith(
            text: transcription,
            isLoading: false,
          ));

      // 5. Add assistant loading bubble.
      assistantMsgId = _uid();
      _addMessage(Message(
        id: assistantMsgId,
        role: MessageRole.assistant,
        isLoading: true,
      ));

      // 6. GPT-4 call with full history (trimmed inside service).
      final gptResponse = await openAiService.chat(
        history: state.messages,
        level: _level,
      );

      // 7. Attach corrections to user message.
      _updateMessage(userMsgId, (m) => m.copyWith(
            corrections: gptResponse.corrections,
          ));

      // 8. Update assistant bubble.
      _updateMessage(assistantMsgId, (m) => m.copyWith(
            text: gptResponse.reply,
            isLoading: false,
            wordDefinitions: gptResponse.wordDefinitions,
          ));

      // Pre-cache word definitions.
      final newCache = Map<String, WordDefinition>.from(state.wordCache);
      for (final wd in gptResponse.wordDefinitions) {
        newCache[wd.word.toLowerCase()] = wd;
      }
      state = state.copyWith(wordCache: newCache);

      // 9. TTS.
      await ttsService.speak(gptResponse.ttsText);

      // Clean up audio file.
      try {
        await audioFile.delete();
      } catch (_) {}
    } catch (e) {
      // Remove orphaned loading bubbles.
      var msgs = List<Message>.from(state.messages);
      if (assistantMsgId != null) {
        msgs.removeWhere((m) => m.id == assistantMsgId && m.isLoading);
      }
      if (userMsgId != null) {
        msgs.removeWhere((m) => m.id == userMsgId && m.isLoading);
      }
      state = state.copyWith(
        messages: msgs,
        error: e.toString(),
      );
    } finally {
      state = state.copyWith(status: ConversationStatus.idle);
    }
  }

  /// Looks up a word definition, using cache when available.
  Future<WordDefinition> lookupWord(String word) async {
    final key = word.toLowerCase();
    if (state.wordCache.containsKey(key)) {
      return state.wordCache[key]!;
    }
    final definition = await openAiService.lookupWord(word);
    final newCache = Map<String, WordDefinition>.from(state.wordCache);
    newCache[key] = definition;
    state = state.copyWith(wordCache: newCache);
    return definition;
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _addMessage(Message msg) {
    state = state.copyWith(
      messages: [...state.messages, msg],
    );
  }

  void _updateMessage(String id, Message Function(Message) updater) {
    state = state.copyWith(
      messages: state.messages
          .map((m) => m.id == id ? updater(m) : m)
          .toList(),
    );
  }

  static int _uidCounter = 0;
  static String _uid() => 'msg_${++_uidCounter}_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void dispose() {
    audioService.dispose();
    ttsService.dispose();
    super.dispose();
  }
}
