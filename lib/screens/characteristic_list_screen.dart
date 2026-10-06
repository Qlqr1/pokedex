import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/stat_utils.dart';
import '../widgets/async_page.dart';
import 'characteristic_screen.dart';

/// Lista de características (a frase que indica o maior IV do Pokémon).
class CharacteristicListScreen extends StatelessWidget {
  const CharacteristicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncPage<List<CharacteristicInfo>>(
      title: 'Características',
      errorText: 'Não foi possível carregar as características.',
      loader: PokemonExtraRepository.instance.getCharacteristics,
      builder: (context, list) => ListView.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final c = list[i];
          return ListTile(
            leading: CircleAvatar(child: Text('${c.id}')),
            title: Text(c.description ?? 'Característica #${c.id}'),
            subtitle: Text(c.highestStat == null
                ? 'Maior IV: —'
                : 'Maior IV: ${statLabel(c.highestStat!)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CharacteristicScreen(characteristic: c)),
            ),
          );
        },
      ),
    );
  }
}