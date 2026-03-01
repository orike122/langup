import 'correction.dart';

class GptResponse {
  final String reply;
  final String ttsText;
  final List<Correction> corrections;
  final List<WordDefinition> wordDefinitions;

  const GptResponse({
    required this.reply,
    required this.ttsText,
    required this.corrections,
    required this.wordDefinitions,
  });

  factory GptResponse.fromJson(Map<String, dynamic> json) {
    final corrections = (json['corrections'] as List<dynamic>? ?? [])
        .map((e) => Correction.fromJson(e as Map<String, dynamic>))
        .toList();

    final wordDefs = (json['word_definitions'] as List<dynamic>? ?? [])
        .map((e) => WordDefinition.fromJson(e as Map<String, dynamic>))
        .toList();

    return GptResponse(
      reply: json['reply'] as String,
      ttsText: json['tts_text'] as String? ?? json['reply'] as String,
      corrections: corrections,
      wordDefinitions: wordDefs,
    );
  }
}
