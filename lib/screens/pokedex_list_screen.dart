import 'package:flutter/material.dart';

import '../repositories/dex_repository.dart';
import '../widgets/named_ref_list_screen.dart';
import 'pokedex_screen.dart';

/// Lista de todas as Pokédexes (Nacional, Kanto, Original Johto...).
class PokedexListScreen extends StatelessWidget {
  const PokedexListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Pokédexes',
      searchable: true,
      searchHint: 'Buscar Pokédex',
      emptyText: 'Nenhuma Pokédex encontrada.',
      loader: DexRepository.instance.getPokedexList,
      leading: (_) => const Icon(Icons.menu_book),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PokedexScreen(pokedexName: r.name)),
      ),
    );
  }
}