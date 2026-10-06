import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/berry_utils.dart';
import '../utils/stat_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/async_page.dart';
import '../widgets/chips_section.dart';
import '../widgets/info_row.dart';
import 'pokeathlon_stat_screen.dart';
import 'stat_screen.dart';

/// Página de uma natureza.
class NatureScreen extends StatelessWidget {
  final String natureName;
  const NatureScreen({super.key, required this.natureName});

  @override
  Widget build(BuildContext context) {
    return AsyncPage<NatureInfo>(
      title: natureName.pretty,
      errorText: 'Não foi possível carregar esta natureza.',
      loader: () => PokemonExtraRepository.instance.getNature(natureName),
      builder: (context, n) {
        void toStat(String s) => Navigator.push(context,
            MaterialPageRoute(builder: (_) => StatScreen(statName: s)));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            InfoRow('Número', '#${n.id}'),
            n.isNeutral
                ? const InfoRow('Status', 'Neutra (não altera nenhum)')
                : Column(children: [
                    InfoRow('Aumenta (+10%)', statLabel(n.increased!),
                        onTap: () => toStat(n.increased!)),
                    InfoRow('Diminui (−10%)', statLabel(n.decreased!),
                        onTap: () => toStat(n.decreased!)),
                  ]),
            InfoRow('Sabor preferido',
                n.likes == null ? '—' : flavorLabel(n.likes!)),
            InfoRow('Sabor que não gosta',
                n.hates == null ? '—' : flavorLabel(n.hates!)),
            ChipsSection(
              title: 'Efeito no Pokéathlon',
              chips: [
                for (final c in n.pokeathlon)
                  ChipItem(
                    '${pokeathlonLabel(c.name)} ${signed(c.change)}',
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              PokeathlonStatScreen(statName: c.name)),
                    ),
                  ),
              ],
            ),
            if (n.styles.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8),
                child: Text(
                  'Preferência de estilo de golpe',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              for (final s in n.styles)
                InfoRow(
                  battleStyleLabel(s.style),
                  'HP baixo ${s.lowHp}% · HP alto ${s.highHp}%',
                ),
            ],
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}