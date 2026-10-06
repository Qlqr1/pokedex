import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/species_utils.dart';
import '../widgets/async_page.dart';
import '../widgets/info_row.dart';
import '../widgets/species_list_page.dart';

/// Página de um grupo de ovo: as espécies que pertencem a ele.
class EggGroupScreen extends StatelessWidget {
  final String groupName; // ex.: "monster"
  const EggGroupScreen({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return AsyncPage<SpeciesGroup>(
      title: eggGroupLabel(groupName),
      errorText: 'Não foi possível carregar este grupo de ovo.',
      loader: () => PokemonExtraRepository.instance.getEggGroup(groupName),
      builder: (context, g) => SpeciesListPage(
        header: Column(children: [
          InfoRow('Número', '#${g.id}'),
          InfoRow('Espécies', '${g.species.length}'),
        ]),
        species: g.species,
      ),
    );
  }
}