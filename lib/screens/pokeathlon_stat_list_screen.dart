import 'package:flutter/material.dart';

import '../repositories/pokemon_extra_repository.dart';
import '../utils/stat_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'pokeathlon_stat_screen.dart';

class PokeathlonStatListScreen extends StatelessWidget {
  const PokeathlonStatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Status do Pokéathlon',
      searchById: false,
      emptyText: 'Nenhum status encontrado.',
      loader: PokemonExtraRepository.instance.getPokeathlonStats,
      label: (r) => pokeathlonLabel(r.name),
      leading: (r) => CircleAvatar(child: Text('${r.id}')),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => PokeathlonStatScreen(statName: r.name)),
      ),
    );
  }
}