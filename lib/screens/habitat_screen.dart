import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/species_utils.dart';
import '../widgets/async_page.dart';
import '../widgets/info_row.dart';
import '../widgets/species_list_page.dart';

/// Página de um habitat: as espécies que vivem nele.
class HabitatScreen extends StatelessWidget {
  final String habitatName; // ex.: "cave"
  const HabitatScreen({super.key, required this.habitatName});

  @override
  Widget build(BuildContext context) {
    return AsyncPage<SpeciesGroup>(
      title: habitatLabel(habitatName),
      errorText: 'Não foi possível carregar este habitat.',
      loader: () => PokemonExtraRepository.instance.getHabitat(habitatName),
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