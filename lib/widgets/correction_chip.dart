import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/correction.dart';

class CorrectionChip extends StatefulWidget {
  final Correction correction;

  const CorrectionChip({super.key, required this.correction});

  @override
  State<CorrectionChip> createState() => _CorrectionChipState();
}

class _CorrectionChipState extends State<CorrectionChip> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          border: Border.all(color: Colors.amber.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.edit_note, size: 16, color: Colors.amber),
                const SizedBox(width: 6),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: widget.correction.original,
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.red,
                          ),
                        ),
                        const TextSpan(text: '  →  '),
                        TextSpan(
                          text: widget.correction.corrected,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: Colors.amber.shade700,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 6),
              Text(
                widget.correction.explanation,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  fontStyle: FontStyle.italic,
                ),
              )
                  .animate()
                  .fadeIn(duration: 200.ms)
                  .slideY(begin: -0.1, end: 0),
            ],
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}
