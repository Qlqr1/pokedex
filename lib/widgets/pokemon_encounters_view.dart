import 'package:flutter/material.dart';

import '../models/location.dart';
import '../screens/location_area_screen.dart';
import '../utils/encounter_labels.dart';
import '../utils/string_utils.dart';
import '../models/named_ref.dart';

/// "Onde achar": encontros do Pokémon agrupados por jogo.
class PokemonEncountersView extends StatelessWidget {
  final List<PokemonAreaEncounter> encounters;
  const PokemonEncountersView({super.key, required this.encounters});

  @override
  Widget build(BuildContext context) {
    if (encounters.isEmpty) {
      return Text(
        'Nenhum local de encontro registrado para este Pokémon. '
        'Ele pode ser obtido por evolução, evento ou troca, ou a PokéAPI '
        'ainda não tem esse dado.',
        style: TextStyle(color: Colors.grey.shade600),
      );
    }

    final byVersion = <String, List<(NamedRef, List<EncounterDetail>)>>{};
    for (final e in encounters) {
      for (final v in e.versions) {
        byVersion.putIfAbsent(v.version, () => []).add((e.area, v.details));
      }
    }
    final versions = byVersion.keys.toList()
      ..sort((a, b) {
        final c = versionRank(a).compareTo(versionRank(b));
        return c != 0 ? c : a.compareTo(b);
      });

    return Column(
      children: [
        for (final v in versions)
          ExpansionTile(
            key: PageStorageKey('enc-$v'),
            initiallyExpanded: versions.length == 1,
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 12),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Text(v.pretty,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('${byVersion[v]!.length} '
                '${byVersion[v]!.length == 1 ? 'área' : 'áreas'}'),
            children: [
              for (final (area, details) in (byVersion[v]!
                ..sort((a, b) => a.$1.name.compareTo(b.$1.name))))
                _AreaBlock(
                  area: area,
                  methods: buildMethodInfos(details,
                      hideChance: versionHasNoRates(v)),
                ),
            ],
          ),
      ],
    );
  }
}

class _AreaBlock extends StatelessWidget {
  final NamedRef area;
  final List<MethodInfo> methods;
  const _AreaBlock({required this.area, required this.methods});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LocationAreaScreen(
                  areaName: area.name,
                  title: area.name.pretty,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(area.name.pretty,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
          for (final m in methods) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '${methodLabel(m.method)} · Nv. '
                '${m.minLevel == m.maxLevel ? m.minLevel : '${m.minLevel}–${m.maxLevel}'}',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 0,
              children: [
                for (final l in m.lines)
                  if (l.condition != null || l.chance != null)
                    Chip(
                      visualDensity: VisualDensity.compact,
                      label: Text([
                        if (l.condition != null) conditionLabel(l.condition!),
                        if (l.chance != null) '${l.chance}%',
                      ].join(' ')),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}