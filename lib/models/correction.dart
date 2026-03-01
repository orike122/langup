class Correction {
  final String original;
  final String corrected;
  final String explanation;

  const Correction({
    required this.original,
    required this.corrected,
    required this.explanation,
  });

  factory Correction.fromJson(Map<String, dynamic> json) {
    return Correction(
      original: json['original'] as String,
      corrected: json['corrected'] as String,
      explanation: json['explanation'] as String,
    );
  }
}

class WordDefinition {
  final String word;
  final String definition;
  final String partOfSpeech;
  final String? gender; // der/die/das or null
  final String example;

  const WordDefinition({
    required this.word,
    required this.definition,
    required this.partOfSpeech,
    this.gender,
    required this.example,
  });

  factory WordDefinition.fromJson(Map<String, dynamic> json) {
    return WordDefinition(
      word: json['word'] as String,
      definition: json['definition'] as String,
      partOfSpeech: json['part_of_speech'] as String,
      gender: json['gender'] as String?,
      example: json['example'] as String,
    );
  }
}
