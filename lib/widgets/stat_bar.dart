import 'package:flutter/material.dart';

import 'stat_colors.dart';

/// Linha de estatística: nome, valor e barra proporcional ao valor máximo.
/// A cor segue a escala do Pokémon Database (veja [statColor]).
/// Com [onTap], a linha inteira vira um link (ex.: para a página do status).
class StatBar extends StatelessWidget {
  final String label;
  final int value;
  final int max;
  final VoidCallback? onTap;

  const StatBar({
    super.key,
    required this.label,
    required this.value,
    this.max = 255,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
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
                  color: statColor(value),
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}