import 'package:flutter/material.dart';

import '../repositories/game_repository.dart';
import '../utils/game_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'generation_screen.dart';
import 'pokedex_list_screen.dart';

/// Grupo Games: lista de gerações.
class GenerationListScreen extends StatelessWidget {
  const GenerationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Games',
      emptyText: 'Nenhuma geração encontrada.',
      loader: GameRepository.instance.getGenerations,
      label: (r) => generationLabel(r.name),
      leading: (r) => CircleAvatar(
        child: Text(generationLabel(r.name).replaceFirst('Geração ', '')),
      ),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => GenerationScreen(generationName: r.name)),
      ),
      footer: [
        ListTile(
          leading: const Icon(Icons.menu_book),
          title: const Text('Pokédexes'),
          subtitle: const Text('Nacional, regionais e especiais'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PokedexListScreen()),
          ),
        ),
      ],
    );
  }
}