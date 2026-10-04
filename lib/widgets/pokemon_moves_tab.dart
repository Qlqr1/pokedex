import 'package:flutter/material.dart';

import '../models/models.dart';
import '../screens/move_screen.dart';
import '../utils/string_utils.dart';
import 'move_tile.dart';

/// Aba "Golpes" de um Pokémon. Os golpes mudam de um jogo para outro, então
/// há um seletor de jogo (padrão: o mais recente). Os golpes ficam agrupados
/// por forma de aprendizado: nível, TM/HM, ovo e tutor.
class PokemonMovesTab extends StatefulWidget {
  final List<PokemonMove> moves;

  const PokemonMovesTab({super.key, required this.moves});

  @override
  State<PokemonMovesTab> createState() => _PokemonMovesTabState();
}

class _MoveEntry {
  final String move;
  final int level;

  const _MoveEntry(this.move, this.level);
}

class _PokemonMovesTabState extends State<PokemonMovesTab> {
  static const List<String> _methodOrder = [
    'level-up',
    'machine',
    'egg',
    'tutor',
  ];

  String? _selected;

  /// Jogos (version groups) em que o Pokémon aprende golpes, do mais antigo ao
  /// mais novo (o ID cresce com a data de lançamento).
  List<String> _versionGroups() {
    final ids = <String, int>{};
    for (final move in widget.moves) {
      for (final detail in move.versionGroupDetails) {
        ids[detail.versionGroup.name] = detail.versionGroup.id ?? 0;
      }
    }
    return ids.keys.toList()..sort((a, b) => ids[a]!.compareTo(ids[b]!));
  }

  Map<String, List<_MoveEntry>> _entriesFor(String versionGroup) {
    final byMethod = <String, List<_MoveEntry>>{};
    for (final move in widget.moves) {
      for (final detail in move.versionGroupDetails) {
        if (detail.versionGroup.name != versionGroup) continue;
        byMethod
            .putIfAbsent(detail.moveLearnMethod.name, () => [])
            .add(_MoveEntry(move.move.name, detail.levelLearnedAt));
      }
    }
    for (final entries in byMethod.values) {
      entries.sort((a, b) {
        final byLevel = a.level.compareTo(b.level);
        return byLevel != 0 ? byLevel : a.move.compareTo(b.move);
      });
    }
    return byMethod;
  }

  String _methodLabel(String method) {
    switch (method) {
      case 'level-up':
        return 'Por nível';
      case 'machine':
        return 'Por TM/HM';
      case 'egg':
        return 'Por ovo';
      case 'tutor':
        return 'Por tutor';
      default:
        return method.pretty;
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = _versionGroups();

    if (groups.isEmpty) {
      return ListView(
        key: const PageStorageKey('tab-golpes'),
        padding: const EdgeInsets.all(16),
        children: const [Text('Nenhum golpe registrado para esta forma.')],
      );
    }

    final selected = groups.contains(_selected) ? _selected! : groups.last;
    final byMethod = _entriesFor(selected);

    final methods = [
      ..._methodOrder.where(byMethod.containsKey),
      ...byMethod.keys.where((m) => !_methodOrder.contains(m)),
    ];

    // Lista achatada: cabeçalhos (String) e golpes (_MoveEntry).
    final rows = <Object>[];
    for (final method in methods) {
      rows.add(method);
      rows.addAll(byMethod[method]!);
    }

    return ListView.builder(
      key: const PageStorageKey('tab-golpes'),
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rows.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return _buildSelector(groups, selected);

        final row = rows[index - 1];
        if (row is String) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              '${_methodLabel(row)} (${byMethod[row]!.length})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          );
        }

        final entry = row as _MoveEntry;
        final method = _currentMethod(rows, index - 1);
        return MoveTile(
          moveName: entry.move,
          leading: method == 'level-up'
              ? (entry.level > 0 ? 'Nv. ${entry.level}' : '—')
              : null,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MoveScreen(moveName: entry.move),
            ),
          ),
        );
      },
    );
  }

  /// Método do cabeçalho mais próximo acima do golpe em [position].
  String _currentMethod(List<Object> rows, int position) {
    for (var i = position; i >= 0; i--) {
      final row = rows[i];
      if (row is String) return row;
    }
    return '';
  }

  Widget _buildSelector(List<String> groups, String selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Jogo:'),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<String>(
              value: selected,
              isExpanded: true,
              items: groups.reversed
                  .map((g) => DropdownMenuItem(value: g, child: Text(g.pretty)))
                  .toList(),
              onChanged: (value) => setState(() => _selected = value),
            ),
          ),
        ],
      ),
    );
  }
}