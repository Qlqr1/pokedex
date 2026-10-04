import 'package:flutter/material.dart';

import '../models/dex.dart';
import '../screens/pokedex_screen.dart';
import '../utils/encounter_labels.dart' show versionRank;
import '../utils/game_utils.dart';
import '../utils/string_utils.dart';

/// Aba "Pokédex" do Pokémon: número em cada Pokédex e os textos por jogo.
class PokemonDexView extends StatelessWidget {
  final SpeciesDex dex;
  const PokemonDexView({super.key, required this.dex});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);

    // Nacional primeiro; depois por nome.
    final numbers = [...dex.numbers]..sort((a, b) {
        if (a.dex == 'national') return -1;
        if (b.dex == 'national') return 1;
        return a.dex.compareTo(b.dex);
      });

    final texts = [...dex.texts]..sort((a, b) {
        int first(DexText t) => t.versions
            .map(versionRank)
            .reduce((x, y) => x < y ? x : y);
        return first(a).compareTo(first(b));
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Número nas Pokédexes', style: titleStyle),
        const SizedBox(height: 8),
        if (numbers.isEmpty)
          const Text('Este Pokémon não consta em nenhuma Pokédex.')
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final n in numbers)
                ActionChip(
                  label: Text('${n.dex.pretty} · #${n.number}'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => PokedexScreen(pokedexName: n.dex)),
                  ),
                ),
            ],
          ),
        const SizedBox(height: 24),
        Text('Textos da Pokédex', style: titleStyle),
        const SizedBox(height: 4),
        if (texts.isEmpty)
          const Text('Nenhum texto registrado.')
        else
          // A PokéAPI não tem textos em português; usamos o inglês.
          for (final t in texts)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (t.versions.toList()
                          ..sort((a, b) =>
                              versionRank(a).compareTo(versionRank(b))))
                        .map(gameLabel)
                        .join(' · '),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(t.text),
                  const SizedBox(height: 4),
                  const Divider(height: 1),
                ],
              ),
            ),
      ],
    );
  }
}