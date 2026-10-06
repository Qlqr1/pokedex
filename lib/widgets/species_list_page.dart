import 'package:flutter/material.dart';

import '../models/named_ref.dart';
import '../utils/search_utils.dart';
import '../utils/string_utils.dart';
import 'list_search_field.dart';
import 'open_pokemon.dart';

/// Conteúdo de página com um cabeçalho e a lista pesquisável de espécies
/// (usado por grupos de ovo e habitats).
class SpeciesListPage extends StatefulWidget {
  final Widget header;
  final List<NamedRef> species;
  const SpeciesListPage(
      {super.key, required this.header, required this.species});

  @override
  State<SpeciesListPage> createState() => _SpeciesListPageState();
}

class _SpeciesListPageState extends State<SpeciesListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = widget.species
        .where((s) => matchesQuery(s.name, s.id, _query))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: widget.header,
          ),
        ),
        if (widget.species.isNotEmpty)
          SliverToBoxAdapter(
            child: ListSearchField(
              hint: 'Buscar espécie',
              onChanged: (v) => setState(() => _query = normalizeQuery(v)),
            ),
          ),
        if (widget.species.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Nenhuma espécie registrada.')),
            ),
          )
        else if (list.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Nenhuma espécie encontrada.')),
            ),
          )
        else
          SliverList.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final s = list[i];
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