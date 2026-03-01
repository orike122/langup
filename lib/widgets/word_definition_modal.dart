import 'package:flutter/material.dart';
import '../models/correction.dart';

class WordDefinitionModal extends StatelessWidget {
  final String word;
  final Future<WordDefinition> Function(String) lookupWord;

  const WordDefinitionModal({
    super.key,
    required this.word,
    required this.lookupWord,
  });

  static Future<void> show(
    BuildContext context, {
    required String word,
    required Future<WordDefinition> Function(String) lookupWord,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          WordDefinitionModal(word: word, lookupWord: lookupWord),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WordDefinition>(
      future: lookupWord(word),
      builder: (context, snapshot) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                Center(
                  child: Text(
                    'Could not load definition.',
                    style: TextStyle(color: Colors.red.shade400),
                  ),
                )
              else
                _DefinitionContent(definition: snapshot.data!),
            ],
          ),
        );
      },
    );
  }
}

class _DefinitionContent extends StatelessWidget {
  final WordDefinition definition;

  const _DefinitionContent({required this.definition});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final gender = definition.gender;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (gender != null) ...[
              Text(
                '$gender ',
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            Text(
              definition.word,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                definition.partOfSpeech,
                style: const TextStyle(fontSize: 11),
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          definition.definition,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        Text(
          'Example',
          style: TextStyle(
            fontSize: 12,
            color: colors.outline,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            definition.example,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
