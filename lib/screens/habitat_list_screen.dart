import 'package:flutter/material.dart';

import '../repositories/pokemon_extra_repository.dart';
import '../utils/species_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'habitat_screen.dart';

class HabitatListScreen extends StatelessWidget {
  const HabitatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Habitats',
      searchById: false,
      emptyText: 'Nenhum habitat encontrado.',
      loader: PokemonExtraRepository.instance.getHabitats,
      label: (r) => habitatLabel(r.name),
      leading: (_) => const Icon(Icons.terrain),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => HabitatScreen(habitatName: r.name)),
      ),
    );
  }
}