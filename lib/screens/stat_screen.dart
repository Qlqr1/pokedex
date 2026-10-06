import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/stat_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/async_page.dart';
import '../widgets/chips_section.dart';
import '../widgets/info_row.dart';
import '../widgets/move_tile.dart' show damageClassLabel;
import 'move_screen.dart';
import 'nature_screen.dart';

/// Página de um status: naturezas e golpes que o alteram.
class StatScreen extends StatelessWidget {
  final String statName;
  const StatScreen({super.key, required this.statName});

  @override
  Widget build(BuildContext context) {
    return AsyncPage<StatInfo>(
      title: statLabel(statName),
      errorText: 'Não foi possível carregar este status.',
      loader: () => PokemonExtraRepository.instance.getStat(statName),
      builder: (context, s) {
        void toNature(String n) => Navigator.push(context,
            MaterialPageRoute(builder: (_) => NatureScreen(natureName: n)));
        void toMove(String m) => Navigator.push(context,
            MaterialPageRoute(builder: (_) => MoveScreen(moveName: m)));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InfoRow('Número', '#${s.id}'),
            InfoRow('Só existe em batalha', s.isBattleOnly ? 'Sim' : 'Não'),
            if (s.damageClass != null)
              InfoRow('Classe de dano', damageClassLabel(s.damageClass)),
            ChipsSection(
              title: 'Naturezas que aumentam',
              chips: [
                for (final n in s.increaseNatures)
                  ChipItem(n.pretty, () => toNature(n)),
              ],
            ),
            ChipsSection(
              title: 'Naturezas que diminuem',
              chips: [
                for (final n in s.decreaseNatures)
                  ChipItem(n.pretty, () => toNature(n)),
              ],
            ),
            ChipsSection(
              title: 'Golpes que aumentam',
              chips: [
                for (final m in s.increaseMoves)
                  ChipItem('${m.name.pretty} ${signed(m.change)}',
                      () => toMove(m.name)),
              ],
            ),
            ChipsSection(
              title: 'Golpes que diminuem',
              chips: [
                for (final m in s.decreaseMoves)
                  ChipItem('${m.name.pretty} ${signed(m.change)}',
                      () => toMove(m.name)),
              ],
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}