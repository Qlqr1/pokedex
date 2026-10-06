import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../utils/stat_utils.dart';
import '../widgets/info_row.dart';
import 'stat_screen.dart';

/// Página de uma característica. Os dados já vêm da lista.
class CharacteristicScreen extends StatelessWidget {
  final CharacteristicInfo characteristic;
  const CharacteristicScreen({super.key, required this.characteristic});

  @override
  Widget build(BuildContext context) {
    final c = characteristic;
    return Scaffold(
      appBar: AppBar(title: Text('Característica #${c.id}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (c.description != null)
            Center(
              child: Text(
                c.description!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 16),
          InfoRow(
            'Maior IV',
            c.highestStat == null ? '—' : statLabel(c.highestStat!),
            onTap: c.highestStat == null
                ? null
                : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => StatScreen(statName: c.highestStat!)),
                    ),
          ),
          InfoRow('Resto do maior IV ÷ 5', '${c.geneModulo}'),
          InfoRow('IVs possíveis', c.possibleValues.join(', ')),
          const SizedBox(height: 16),
          Text(
            'Esta frase aparece na tela de resumo do Pokémon e indica qual é o '
            'seu maior IV e o resto da divisão desse IV por 5.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}