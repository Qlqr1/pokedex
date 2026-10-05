import 'package:flutter/material.dart';

import '../models/contest.dart';
import '../utils/string_utils.dart';
import '../widgets/info_row.dart';
import 'move_screen.dart';

/// Página de um efeito de concurso. Os dados já vêm da lista.
class ContestEffectScreen extends StatelessWidget {
  final ContestEffectInfo effect;
  final bool superContest;
  const ContestEffectScreen(
      {super.key, required this.effect, required this.superContest});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);

    Widget section(String title, String text) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(title, style: titleStyle),
            ),
            Text(text),
          ],
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${superContest ? 'Efeito de Super Contest' : 'Efeito de concurso'} #${effect.id}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoRow('Número', '#${effect.id}'),
          InfoRow('Apelo', effect.appeal?.toString() ?? '—'),
          if (!superContest) InfoRow('Jam', effect.jam?.toString() ?? '—'),
          // A PokéAPI não tem textos em português; usamos o inglês.
          if (effect.effect != null) section('Efeito', effect.effect!),
          if (effect.flavor != null)
            section('Descrição no jogo', effect.flavor!),
          if (effect.moves.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child:
                  Text('Golpes com este efeito (${effect.moves.length})',
                      style: titleStyle),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final m in effect.moves)
                  ActionChip(
                    label: Text(m.pretty),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => MoveScreen(moveName: m)),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}