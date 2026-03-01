import 'correction.dart';

enum MessageRole { user, assistant }

class Message {
  final String id;
  final MessageRole role;
  final String? text; // null while loading
  final bool isLoading;
  final List<Correction> corrections;
  final List<WordDefinition> wordDefinitions;

  const Message({
    required this.id,
    required this.role,
    this.text,
    this.isLoading = false,
    this.corrections = const [],
    this.wordDefinitions = const [],
  });

  Message copyWith({
    String? text,
    bool? isLoading,
    List<Correction>? corrections,
    List<WordDefinition>? wordDefinitions,
  }) {
    return Message(
      id: id,
      role: role,
      text: text ?? this.text,
      isLoading: isLoading ?? this.isLoading,
      corrections: corrections ?? this.corrections,
      wordDefinitions: wordDefinitions ?? this.wordDefinitions,
    );
  }
}
