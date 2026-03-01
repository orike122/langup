import '../models/level.dart';

class LevelQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final CefrLevel targetLevel; // difficulty this question probes

  const LevelQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.targetLevel,
  });
}

const List<LevelQuestion> levelQuestions = [
  // A1
  LevelQuestion(
    question: 'What is the German word for "apple"?',
    options: ['Apfel', 'Brot', 'Milch', 'Wasser'],
    correctIndex: 0,
    targetLevel: CefrLevel.a1,
  ),
  LevelQuestion(
    question: 'Which sentence is correct?',
    options: [
      'Ich bin müde.',
      'Ich bist müde.',
      'Ich ist müde.',
      'Ich sind müde.',
    ],
    correctIndex: 0,
    targetLevel: CefrLevel.a1,
  ),
  // A2
  LevelQuestion(
    question: 'Choose the correct article: ___ Hund ist groß.',
    options: ['Der', 'Die', 'Das', 'Den'],
    correctIndex: 0,
    targetLevel: CefrLevel.a2,
  ),
  LevelQuestion(
    question: 'What does "Ich habe Hunger" mean?',
    options: [
      'I am hungry.',
      'I am angry.',
      'I am tired.',
      'I am happy.',
    ],
    correctIndex: 0,
    targetLevel: CefrLevel.a2,
  ),
  // B1
  LevelQuestion(
    question: 'Fill in: Gestern ___ ich ins Kino gegangen.',
    options: ['bin', 'habe', 'war', 'hatte'],
    correctIndex: 0,
    targetLevel: CefrLevel.b1,
  ),
  LevelQuestion(
    question: 'Which is a separable verb?',
    options: ['aufmachen', 'bekommen', 'verstehen', 'erklären'],
    correctIndex: 0,
    targetLevel: CefrLevel.b1,
  ),
  // B2
  LevelQuestion(
    question: 'Choose the correct Genitiv: Das Auto ___ Mannes ist rot.',
    options: ['des', 'dem', 'den', 'der'],
    correctIndex: 0,
    targetLevel: CefrLevel.b2,
  ),
  LevelQuestion(
    question: 'Identify the subordinating conjunction:',
    options: ['weil', 'und', 'aber', 'oder'],
    correctIndex: 0,
    targetLevel: CefrLevel.b2,
  ),
  // C1
  LevelQuestion(
    question: 'Which sentence uses Konjunktiv II correctly?',
    options: [
      'Wenn ich Zeit hätte, käme ich.',
      'Wenn ich Zeit habe, komme ich.',
      'Wenn ich Zeit haben, kommen ich.',
      'Wenn ich Zeit hatte, kam ich.',
    ],
    correctIndex: 0,
    targetLevel: CefrLevel.c1,
  ),
  LevelQuestion(
    question: 'What does "nichtsdestotrotz" mean?',
    options: [
      'nevertheless',
      'immediately',
      'unfortunately',
      'furthermore',
    ],
    correctIndex: 0,
    targetLevel: CefrLevel.c1,
  ),
];

/// Maps score (0–10) to CEFR level.
CefrLevel scoreToLevel(int score) {
  if (score <= 1) return CefrLevel.a1;
  if (score <= 3) return CefrLevel.a2;
  if (score <= 5) return CefrLevel.b1;
  if (score <= 7) return CefrLevel.b2;
  if (score <= 9) return CefrLevel.c1;
  return CefrLevel.c2;
}
