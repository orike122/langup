import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../constants/prompts.dart';
import '../models/correction.dart';
import '../models/gpt_response.dart';
import '../models/level.dart';
import '../models/message.dart';

class OpenAiService {
  late final Dio _dio;

  OpenAiService() {
    _dio = Dio(BaseOptions(
      baseUrl: openAiBaseUrl,
      headers: {
        'Authorization': 'Bearer $openAiKey',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  /// Transcribes audio via Whisper.
  Future<String> transcribeAudio(File audioFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audioFile.path,
        filename: 'audio.m4a',
      ),
      'model': whisperModel,
      'language': 'de',
    });

    final response = await _dio.post(
      '/audio/transcriptions',
      data: formData,
    );

    return response.data['text'] as String;
  }

  /// Sends the conversation history to GPT-4 and returns a structured response.
  Future<GptResponse> chat({
    required List<Message> history,
    required CefrLevel level,
  }) async {
    final systemPrompt = buildSystemPrompt(level);

    // Trim to last 20 turns (20 messages = 10 back-and-forth pairs).
    final trimmed = history.length > 20 ? history.sublist(history.length - 20) : history;

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...trimmed
          .where((m) => !m.isLoading && m.text != null)
          .map((m) => {
                'role': m.role == MessageRole.user ? 'user' : 'assistant',
                'content': m.text!,
              }),
    ];

    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': gptModel,
        'messages': messages,
        'temperature': 0.7,
        'response_format': {'type': 'json_object'},
      },
    );

    final rawContent =
        response.data['choices'][0]['message']['content'] as String;
    final cleanedContent = _stripFences(rawContent);
    final json = jsonDecode(cleanedContent) as Map<String, dynamic>;
    return GptResponse.fromJson(json);
  }

  /// On-demand word definition lookup.
  Future<WordDefinition> lookupWord(String word) async {
    final prompt = buildWordLookupPrompt(word);

    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': gptModel,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.3,
        'response_format': {'type': 'json_object'},
      },
    );

    final rawContent =
        response.data['choices'][0]['message']['content'] as String;
    final cleanedContent = _stripFences(rawContent);
    final json = jsonDecode(cleanedContent) as Map<String, dynamic>;
    return WordDefinition.fromJson(json);
  }

  /// Strips ` ```json ... ``` ` fence wrappers that GPT sometimes adds.
  String _stripFences(String raw) {
    final trimmed = raw.trim();
    final fenceRe = RegExp(r'^```(?:json)?\s*([\s\S]*?)\s*```$');
    final match = fenceRe.firstMatch(trimmed);
    return match != null ? match.group(1)! : trimmed;
  }
}
