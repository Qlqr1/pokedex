import 'package:flutter/material.dart';

import '../models/evolution_trigger.dart';
import '../repositories/evolution_repository.dart';
import '../utils/evolution_utils.dart';
import '../utils/search_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/info_row.dart';
import '../widgets/list_search_field.dart';
import '../widgets/open_pokemon.dart';

/// Página de um gatilho de evolução: descrição e as espécies que resultam
/// de evoluções com esse gatilho (com busca, pois há centenas no level-up).
class EvolutionTriggerScreen extends StatefulWidget {
  final String triggerName; // ex.: "level-up"
  const EvolutionTriggerScreen({super.key, required this.triggerName});

  @override
  State<EvolutionTriggerScreen> createState() => _EvolutionTriggerScreenState();
}

class _EvolutionTriggerScreenState extends State<EvolutionTriggerScreen> {
  late Future<EvolutionTriggerInfo> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = EvolutionRepository.instance.getTrigger(widget.triggerName);
  }

  void _retry() => setState(() =>
      _future = EvolutionRepository.instance.getTrigger(widget.triggerName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(triggerLabel(widget.triggerName))),
      body: FutureBuilder<EvolutionTriggerInfo>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar este gatilho.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            );
          }
          return _content(snap.data!);
        },
      ),
    );
  }

  Widget _content(EvolutionTriggerInfo t) {
    final description = triggerDescription(t.name);
    final species = t.species
        .where((s) => matchesQuery(s.name, s.id, _query))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (description != null) ...[
                  Text(description),
                  const SizedBox(height: 12),
                ],
                InfoRow('Nome oficial (API)', t.displayName ?? t.name.pretty),
                InfoRow('Identificador', t.name),
                InfoRow('Espécies que resultam',
                    '${t.species.length}'),
              ],
            ),
          ),
        ),
        if (t.species.isNotEmpty)
          SliverToBoxAdapter(
            child: ListSearchField(
              hint: 'Buscar espécie',
              onChanged: (v) => setState(() => _query = normalizeQuery(v)),
            ),
          ),
        if (t.species.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                  child: Text('Nenhuma espécie registrada para este gatilho.')),
            ),
          )
        else if (species.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Nenhuma espécie encontrada.')),
            ),
          )
        else
          SliverList.builder(
            itemCount: species.length,
            itemBuilder: (context, i) {
              final s = species[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${s.id}.png',
                  ),
                ),
                title: Text(
                    '#${s.id.toString().padLeft(4, '0')}  ${s.name.pretty}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPokemon(context, s.id),
              );
            },
          ),
      ],
    );
  }
}