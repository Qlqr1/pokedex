import 'package:flutter/material.dart';

import '../repositories/pokemon_repository.dart';
import '../screens/pokemon_screen.dart';
import '../services/pokeapi_service.dart'; // PokeApiException
import '../utils/learner_filter.dart';
import '../utils/string_utils.dart';

class LearnerEntry {
  final String name; // ex.: "charizard-mega-x"
  final bool isHidden; // habilidade oculta (só faz sentido na tela de habilidade)
  const LearnerEntry(this.name, {this.isHidden = false});
}

/// Seção padrão "pokémons que têm esta habilidade / aprendem este golpe".
/// Usada pelas telas de habilidade e de golpe: filtra formas desnecessárias
/// (GMax, bonés/roupas do Pikachu...), mostra chips leves e abre a PokemonScreen.
class PokemonLearnersSection extends StatefulWidget {
  final String title;
  final String emptyText;
  final List<LearnerEntry> learners;
  final int initialCount;

  const PokemonLearnersSection({
    super.key,
    required this.title,
    required this.emptyText,
    required this.learners,
    this.initialCount = 40,
  });

  @override
  State<PokemonLearnersSection> createState() => _PokemonLearnersSectionState();
}

class _PokemonLearnersSectionState extends State<PokemonLearnersSection> {
  bool _expanded = false;
  String? _loading;

  Future<void> _open(String name) async {
    if (_loading != null) return;
    setState(() => _loading = name);
    try {
      final pokemon = await PokemonRepository.shared.getPokemon(name);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PokemonScreen(pokemon: pokemon)),
      );
    } on PokeApiException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir este Pokémon.')),
      );
    } finally {
      if (mounted) setState(() => _loading = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final all =
        widget.learners.where((l) => showInLearnerList(l.name)).toList();
    final shown = _expanded ? all : all.take(widget.initialCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            '${widget.title} (${all.length})',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (all.isEmpty)
          Text(widget.emptyText)
        else
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...shown.map((l) => ActionChip(
                    avatar: _loading == l.name
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : (l.isHidden
                            ? const Icon(Icons.visibility_off, size: 16)
                            : null),
                    label: Text(l.name.pretty),
                    onPressed: _loading == null ? () => _open(l.name) : null,
                  )),
              if (all.length > shown.length)
                ActionChip(
                  label: Text('Ver mais (+${all.length - shown.length})'),
                  onPressed: () => setState(() => _expanded = true),
                ),
            ],
          ),
      ],
    );
  }
}