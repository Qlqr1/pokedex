import 'package:flutter/material.dart';

import '../repositories/pokemon_extra_repository.dart';
import '../utils/species_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'egg_group_screen.dart';

class EggGroupListScreen extends StatelessWidget {
  const EggGroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Grupos de ovo',
      searchById: false,
      emptyText: 'Nenhum grupo de ovo encontrado.',
      loader: PokemonExtraRepository.instance.getEggGroups,
      label: (r) => eggGroupLabel(r.name),
      leading: (_) => const Icon(Icons.egg),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EggGroupScreen(groupName: r.name)),
      ),
    );
  }
}