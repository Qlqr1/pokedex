import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/pokemon_repository.dart';
import '../utils/string_utils.dart';
import '../widgets/move_tile.dart'; // damageClassLabel
import '../widgets/type_badge.dart';
import '../widgets/pokemon_learners_section.dart';

/// Página de um golpe: tipo, categoria, números, efeito, mudanças de status
/// e quais Pokémon o aprendem.
class MoveScreen extends StatefulWidget {
  final String moveName;

  const MoveScreen({super.key, required this.moveName});

  @override
  State<MoveScreen> createState() => _MoveScreenState();
}

class _MoveScreenState extends State<MoveScreen> {
  final PokemonRepository _repository = PokemonRepository.shared;
  late Future<Move> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.getMove(widget.moveName);
  }

  void _retry() =>
      setState(() => _future = _repository.getMove(widget.moveName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.moveName.pretty)),
      body: FutureBuilder<Move>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Não foi possível carregar este golpe.'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _retry,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildContent(snapshot.data as Move);
        },
      ),
    );
  }

  Widget _buildContent(Move move) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TypeBadge(type: move.type.name),
            Chip(label: Text(damageClassLabel(move.damageClass?.name))),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 12,
          children: [
            _Stat(label: 'Poder', value: '${move.power ?? '—'}'),
            _Stat(
              label: 'Precisão',
              value: move.accuracy != null ? '${move.accuracy}%' : '—',
            ),
            _Stat(label: 'PP', value: '${move.pp ?? '—'}'),
            _Stat(label: 'Prioridade', value: '${move.priority}'),
            if (move.effectChance != null)
              _Stat(label: 'Chance do efeito', value: '${move.effectChance}%'),
          ],
        ),
        _Title('Efeito'),
        Text(_effectText(move)),
        const SizedBox(height: 12),
        Text(
          'Alvo: ${move.target?.name.pretty ?? '—'}'
          '   Geração: ${move.generation?.name.replaceFirst('generation-', '').toUpperCase() ?? '—'}',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        if (move.statChanges.isNotEmpty) ...[
          _Title('Alterações de status'),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: move.statChanges
                .map(
                  (c) => Chip(
                    label: Text(
                      '${c.stat.name.pretty} ${c.change > 0 ? '+' : ''}${c.change}',
                    ),
                  ),
                )
                .toList(),
          ),
        ],
        PokemonLearnersSection(
          title: 'Aprendido por',
          emptyText: 'Nenhum Pokémon aprende este golpe.',
          learners: move.learnedByPokemon
              .map((p) => LearnerEntry(p.name))
              .toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Texto em inglês (a PokéAPI não tem em português). O texto da API usa
  /// "$effect_chance" como marcador, que trocamos pelo valor.
  String _effectText(Move move) {
    for (final entry in move.effectEntries) {
      if (entry.language.name == 'en') {
        return entry.shortEffect.replaceAll(
          r'$effect_chance',
          '${move.effectChance ?? ''}',
        );
      }
    }
    return 'Sem descrição disponível.';
  }
}

class _Title extends StatelessWidget {
  final String text;

  const _Title(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
