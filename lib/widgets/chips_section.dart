import 'package:flutter/material.dart';

class ChipItem {
  final String label;
  final VoidCallback onTap;
  const ChipItem(this.label, this.onTap);
}

/// Título + chips clicáveis. Mostra os [initialCount] primeiros e um botão
/// "Ver mais" (algumas listas têm centenas de itens).
class ChipsSection extends StatefulWidget {
  final String title;
  final List<ChipItem> chips;
  final int initialCount;

  const ChipsSection({
    super.key,
    required this.title,
    required this.chips,
    this.initialCount = 40,
  });

  @override
  State<ChipsSection> createState() => _ChipsSectionState();
}

class _ChipsSectionState extends State<ChipsSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.chips.isEmpty) return const SizedBox.shrink();
    final shown =
        _expanded ? widget.chips : widget.chips.take(widget.initialCount).toList();
    final rest = widget.chips.length - shown.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            '${widget.title} (${widget.chips.length})',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final c in shown)
              ActionChip(label: Text(c.label), onPressed: c.onTap),
            if (rest > 0)
              ActionChip(
                label: Text('Ver mais (+$rest)'),
                onPressed: () => setState(() => _expanded = true),
              ),
          ],
        ),
      ],
    );
  }
}