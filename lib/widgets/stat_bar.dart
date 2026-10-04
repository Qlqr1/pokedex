import 'package:flutter/material.dart';

/// Linha de estatística: nome, valor e barra proporcional ao valor máximo.
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.max = 255,
  });

  Color get _color {
    if (value < 50) return Colors.redAccent;
    if (value < 80) return Colors.orange;
    if (value < 110) return Colors.lightGreen;
    return Colors.teal;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(width: 96, child: Text(label)),
          SizedBox(
            width: 36,
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / max).clamp(0.0, 1.0),
                minHeight: 8,
                color: _color,
                backgroundColor: Colors.grey.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}