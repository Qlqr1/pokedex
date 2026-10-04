import 'package:flutter/material.dart';

import '../models/game.dart';
import '../repositories/game_repository.dart';
import '../utils/game_utils.dart';
import '../utils/machine_utils.dart' show versionGroupLabel;
import '../utils/string_utils.dart';
import 'pokedex_screen.dart';
import 'region_screen.dart';

/// Página de um jogo: geração, grupo de versões, regiões, pokédexes e
/// métodos de aprendizado de golpes.
class GameScreen extends StatefulWidget {
  final String versionName; // ex.: "red"
  const GameScreen({super.key, required this.versionName});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Future<GameDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = GameRepository.instance.getGame(widget.versionName);
  }

  void _retry() => setState(
      () => _future = GameRepository.instance.getGame(widget.versionName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(gameLabel(widget.versionName))),
      body: FutureBuilder<GameDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar este jogo.'),
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

  Widget _section(String title, List<Widget> chips) {
    if (chips.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Wrap(spacing: 8, runSpacing: 4, children: chips),
      ],
    );
  }

  Widget _content(GameDetail g) {
    final others = g.siblings.where((s) => s != g.name).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text('#${g.id}', style: TextStyle(color: Colors.grey.shade600)),
        ),
        Center(
          child: Text(
            gameLabel(g.name),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        _InfoRow('Geração', generationLabel(g.generation)),
        _InfoRow('Grupo de jogos', versionGroupLabel(g.versionGroup)),

        _section(
          'Regiões',
          g.regions
              .map((r) => ActionChip(
                    label: Text(r.pretty),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RegionScreen(regionName: r)),
                    ),
                  ))
              .toList(),
        ),
        _section(
          'Outros jogos do grupo',
          others
              .map((s) => ActionChip(
                    label: Text(gameLabel(s)),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => GameScreen(versionName: s)),
                    ),
                  ))
              .toList(),
        ),
        _section(
          'Pokédexes',
          g.pokedexes
              .map((p) => ActionChip(
                    label: Text(p.pretty),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PokedexScreen(pokedexName: p)),
                    ),
                  ))
              .toList(),
        ),
        _section(
          'Métodos de aprendizado de golpes',
          g.moveLearnMethods.map((m) => Chip(label: Text(m.pretty))).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(label,
                    style: TextStyle(color: Colors.grey.shade700)),
              ),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}