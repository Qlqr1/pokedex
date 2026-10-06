import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/game_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/async_page.dart';
import '../widgets/chips_section.dart';
import '../widgets/info_row.dart';
import '../widgets/move_tile.dart' show damageClassLabel;
import '../widgets/pokemon_learners_section.dart';
import '../widgets/type_badge.dart';
import 'move_screen.dart';

/// Página de um tipo: relações de dano, Pokémon e golpes do tipo.
class TypeScreen extends StatelessWidget {
  final String typeName;
  const TypeScreen({super.key, required this.typeName});

  @override
  Widget build(BuildContext context) {
    return AsyncPage<TypeInfo>(
      title: typeName.pretty,
      errorText: 'Não foi possível carregar este tipo.',
      loader: () => PokemonExtraRepository.instance.getType(typeName),
      builder: (context, t) => _content(context, t),
    );
  }

  Widget _group(BuildContext context, String title, List<String> types,
      String suffix) {
    if (types.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final n in types)
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TypeScreen(typeName: n)),
                ),
                child: TypeBadge(type: n, suffix: suffix),
              ),
          ],
        ),
      ],
    );
  }

  Widget _title(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      );

  Widget _content(BuildContext context, TypeInfo t) {
    final r = t.relations;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: TypeBadge(type: t.name)),
        const SizedBox(height: 16),
        InfoRow('Número', '#${t.id}'),
        if (t.generation != null)
          InfoRow('Introduzido na', generationLabel(t.generation!)),
        if (t.damageClass != null)
          InfoRow('Classe de dano', damageClassLabel(t.damageClass)),

        _title(context, 'Ao atacar'),
        _group(context, 'Super eficaz contra', r['double_damage_to'] ?? [], '×2'),
        _group(context, 'Pouco eficaz contra', r['half_damage_to'] ?? [], '×½'),
        _group(context, 'Não afeta', r['no_damage_to'] ?? [], '×0'),

        _title(context, 'Ao defender'),
        _group(context, 'Fraco contra', r['double_damage_from'] ?? [], '×2'),
        _group(context, 'Resiste a', r['half_damage_from'] ?? [], '×½'),
        _group(context, 'Imune a', r['no_damage_from'] ?? [], '×0'),

        PokemonLearnersSection(
          title: 'Pokémon do tipo',
          emptyText: 'Nenhum Pokémon deste tipo.',
          learners: t.pokemon.map((p) => LearnerEntry(p.name)).toList(),
        ),
        ChipsSection(
          title: 'Golpes do tipo',
          chips: [
            for (final m in t.moves)
              ChipItem(
                m.pretty,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MoveScreen(moveName: m)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}