import 'package:flutter/material.dart';

import '../models/dex.dart';
import '../repositories/dex_repository.dart';
import '../utils/machine_utils.dart' show versionGroupLabel;
import '../utils/search_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_search_field.dart';
import '../widgets/open_pokemon.dart';
import 'region_screen.dart';

/// Página de uma Pokédex: informações e a lista de entradas (número + Pokémon).
class PokedexScreen extends StatefulWidget {
  final String pokedexName; // ex.: "kanto"
  const PokedexScreen({super.key, required this.pokedexName});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  late Future<PokedexDetail> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = DexRepository.instance.getPokedex(widget.pokedexName);
  }

  void _retry() => setState(
      () => _future = DexRepository.instance.getPokedex(widget.pokedexName));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PokedexDetail>(
      future: _future,
      builder: (context, snap) {
        final title = snap.data?.displayName ?? widget.pokedexName.pretty;
        if (snap.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar esta Pokédex.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: _content(snap.data!),
        );
      },
    );
  }

  Widget _content(PokedexDetail d) {
    final entries = d.entries
        .where((e) => matchesQuery(e.speciesName, e.number, _query))
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _info(d)),
        SliverToBoxAdapter(
          child: ListSearchField(
            hint: 'Buscar por nome ou número',
            onChanged: (v) => setState(() => _query = normalizeQuery(v)),
          ),
        ),
        if (entries.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Nenhuma entrada encontrada.')),
            ),
          )
        else
          SliverList.builder(
            itemCount: entries.length,
            itemBuilder: (context, i) {
              final e = entries[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: NetworkImage(
                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${e.speciesId}.png',
                  ),
                ),
                title: Text(
                    '#${e.number.toString().padLeft(3, '0')}  ${e.speciesName.pretty}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPokemon(context, e.speciesId),
              );
            },
          ),
      ],
    );
  }

  Widget _info(PokedexDetail d) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (d.description != null && d.description!.isNotEmpty)
            Text(d.description!),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(label: Text('${d.entries.length} entradas')),
              if (!d.isMainSeries) const Chip(label: Text('Fora da série principal')),
              if (d.region != null)
                ActionChip(
                  avatar: const Icon(Icons.map, size: 16),
                  label: Text(d.region!.pretty),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RegionScreen(regionName: d.region!)),
                  ),
                ),
              for (final g in d.versionGroups)
                Chip(label: Text(versionGroupLabel(g))),
            ],
          ),
        ],
      ),
    );
  }
}