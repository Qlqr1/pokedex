import 'package:flutter/material.dart';

import '../models/location.dart';
import '../repositories/location_repository.dart';
import '../utils/encounter_labels.dart';
import '../utils/string_utils.dart';
import '../widgets/open_conditions.dart';
import '../widgets/open_pokemon.dart';
import 'encounter_method_screen.dart';

/// Página de uma área: métodos de encontro e Pokémon que aparecem nela,
/// com filtro por jogo.
class LocationAreaScreen extends StatefulWidget {
  final String areaName;
  final String title;
  final String? locationTitle;

  const LocationAreaScreen({
    super.key,
    required this.areaName,
    required this.title,
    this.locationTitle,
  });

  @override
  State<LocationAreaScreen> createState() => _LocationAreaScreenState();
}

class _LocationAreaScreenState extends State<LocationAreaScreen> {
  late Future<LocationArea> _future;
  String? _version; // null = todos os jogos

  @override
  void initState() {
    super.initState();
    _future = LocationRepository.instance.getLocationArea(widget.areaName);
  }

  void _retry() => setState(() {
        _future = LocationRepository.instance.getLocationArea(widget.areaName);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<LocationArea>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar esta área.'),
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

  Widget _content(LocationArea area) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);

    final rows = <(AreaEncounter, EncounterSummary)>[];
    for (final e in area.encounters) {
      final s =
          e.summaryFor(_version, unreliable: area.unreliableChances);
      if (s != null) rows.add((e, s));
    }
    rows.sort((a, b) {
      final c = b.$2.bestChance.compareTo(a.$2.bestChance);
      return c != 0 ? c : a.$1.pokemon.name.compareTo(b.$1.pokemon.name);
    });
    final conditions = <String>{};
    for (final e in area.encounters) {
      for (final v in e.versions) {
        if (_version != null && v.version != _version) continue;
        for (final d in v.details) {
          conditions.addAll(d.conditions);
        }
      }
    }
    final conditionList = conditions.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.locationTitle != null)
          Text(widget.locationTitle!,
              style: TextStyle(color: Colors.grey.shade600)),
        if (area.encounterMethods.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text('Métodos de encontro', style: titleStyle),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: area.encounterMethods
                .map((m) => ActionChip(
                      label: Text(methodLabel(m)),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                EncounterMethodScreen(methodName: m)),
                      ),
                    ))
                .toList(),
          ),
        ],
        if (conditionList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Text('Condições', style: titleStyle),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: conditionList
                .map((c) => ActionChip(
                      label: Text(conditionLabel(c)),
                      onPressed: () => openConditions(context, [c]),
                    ))
                .toList(),
          ),
        ],
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text('Pokémon (${rows.length})', style: titleStyle),
        ),
        if (area.versions.length > 1)
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todos os jogos'),
                    selected: _version == null,
                    onSelected: (_) => setState(() => _version = null),
                  ),
                ),
                for (final v in area.versions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(v.pretty),
                      selected: _version == v,
                      onSelected: (_) => setState(() => _version = v),
                    ),
                  ),
              ],
            ),
          ),
        if (area.encounters.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Nenhum encontro registrado nesta área.'),
          )
        else if (rows.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('Nenhum encontro neste jogo.'),
          ),
        for (final (enc, s) in rows)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(enc.pokemon.name.pretty),
            subtitle: Text(
              'Nv. ${s.minLevel == s.maxLevel ? s.minLevel : '${s.minLevel}–${s.maxLevel}'}'
              ' · ${s.methodChances.entries.map((m) => m.value == null ? m.key.pretty : '${m.key.pretty} ${m.value}%').join(' · ')}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => openPokemon(context, enc.pokemon.id),
          ),
      ],
    );
  }
}