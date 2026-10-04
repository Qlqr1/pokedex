import 'package:flutter/material.dart';

import '../repositories/game_repository.dart';
import '../utils/game_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'game_screen.dart';

/// Jogos de uma geração (algumas têm vários).
class GenerationScreen extends StatelessWidget {
  final String generationName; // ex.: "generation-i"
  const GenerationScreen({super.key, required this.generationName});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: generationLabel(generationName),
      emptyText: 'Nenhum jogo encontrado nesta geração.',
      loader: () =>
          GameRepository.instance.getGenerationGames(generationName),
      label: (r) => gameLabel(r.name),
      leading: (_) => const Icon(Icons.sports_esports),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GameScreen(versionName: r.name)),
      ),
    );
  }
}