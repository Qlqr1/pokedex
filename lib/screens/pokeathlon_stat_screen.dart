import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/stat_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/async_page.dart';
import '../widgets/chips_section.dart';
import '../widgets/info_row.dart';
import 'nature_screen.dart';

/// Página de um status do Pokéathlon: naturezas que o aumentam e diminuem.
class PokeathlonStatScreen extends StatelessWidget {
  final String statName; // ex.: "speed"
  const PokeathlonStatScreen({super.key, required this.statName});

  @override
  Widget build(BuildContext context) {
    return AsyncPage<PokeathlonStatInfo>(
      title: pokeathlonLabel(statName),
      errorText: 'Não foi possível carregar este status.',
      loader: () => PokemonExtraRepository.instance.getPokeathlonStat(statName),
      builder: (context, s) {
        List<ChipItem> chips(List<NameChange> l) => [
              for (final n in l)
                ChipItem(
                  '${n.name.pretty} ${signed(n.change)}',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => NatureScreen(natureName: n.name)),
                  ),
                ),
            ];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InfoRow('Número', '#${s.id}'),
            ChipsSection(
                title: 'Naturezas que aumentam', chips: chips(s.increase)),
            ChipsSection(
                title: 'Naturezas que diminuem', chips: chips(s.decrease)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}