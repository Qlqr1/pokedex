import 'package:flutter/material.dart';
import '../models/ability.dart';
import '../repositories/ability_repository.dart';
import '../utils/string_utils.dart';
import '../widgets/pokemon_learners_section.dart';

class AbilityScreen extends StatefulWidget {
  final String idOrName;
  const AbilityScreen({super.key, required this.idOrName});

  @override
  State<AbilityScreen> createState() => _AbilityScreenState();
}

class _AbilityScreenState extends State<AbilityScreen> {
  late Future<Ability> _future;

  @override
  void initState() {
    super.initState();
    _future = AbilityRepository.instance.getAbility(widget.idOrName);
  }

  void _retry() => setState(() {
        _future = AbilityRepository.instance.getAbility(widget.idOrName);
      });

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.titleMedium;
    return FutureBuilder<Ability>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.idOrName.pretty)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(widget.idOrName.pretty)),
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar esta habilidade.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            ),
          );
        }
        final a = snap.data!;
        return Scaffold(
          appBar: AppBar(title: Text(a.displayName ?? a.name.pretty)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(spacing: 8, children: [
                Chip(label: Text('#${a.id}')),
                Chip(
                    label: Text(a.generation
                        .replaceAll('generation-', 'Geração ')
                        .toUpperCase())),
                if (!a.isMainSeries)
                  const Chip(label: Text('Fora da série principal')),
              ]),
              const SizedBox(height: 12),
              if (a.shortEffect != null) ...[
                Text('Resumo', style: title),
                const SizedBox(height: 4),
                Text(a.shortEffect!),
                const SizedBox(height: 16),
              ],
              if (a.effect != null) ...[
                Text('Efeito', style: title),
                const SizedBox(height: 4),
                Text(a.effect!),
                const SizedBox(height: 16),
              ],
              if (a.flavorText != null) ...[
                Text('Descrição no jogo', style: title),
                const SizedBox(height: 4),
                Text(a.flavorText!,
                    style: const TextStyle(fontStyle: FontStyle.italic)),
              ],
              PokemonLearnersSection(
                title: 'Pokémon com esta habilidade',
                emptyText: 'Nenhum Pokémon tem esta habilidade.',
                learners: a.pokemon
                    .map((p) =>
                        LearnerEntry(p.pokemon.name, isHidden: p.isHidden))
                    .toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}