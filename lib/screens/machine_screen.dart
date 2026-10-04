import 'package:flutter/material.dart';

import '../models/machine.dart';
import '../repositories/machine_repository.dart';
import '../utils/machine_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/item_sprite.dart';
import 'move_screen.dart';

/// Página de uma TM/HM/TR: imagem no topo e o golpe que ela ensina em cada
/// jogo (o golpe de uma mesma TM muda de geração para geração).
class MachineScreen extends StatefulWidget {
  final String itemName; // ex.: "tm01"
  const MachineScreen({super.key, required this.itemName});

  @override
  State<MachineScreen> createState() => _MachineScreenState();
}

class _MachineScreenState extends State<MachineScreen> {
  late Future<MachineInfo> _future;

  @override
  void initState() {
    super.initState();
    _future = MachineRepository.instance.getMachine(widget.itemName);
  }

  void _retry() => setState(
      () => _future = MachineRepository.instance.getMachine(widget.itemName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(machineLabel(widget.itemName))),
      body: FutureBuilder<MachineInfo>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar esta máquina.'),
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

  Widget _content(MachineInfo info) {
    // Agrupa por golpe: "Thunderbolt — Red / Blue, Yellow, ..."
    final games = <String, List<String>>{};
    for (final e in info.entries) {
      games.putIfAbsent(e.move, () => []).add(e.versionGroup);
    }
    for (final g in games.values) {
      g.sort((a, b) => versionGroupRank(a).compareTo(versionGroupRank(b)));
    }
    final moves = games.keys.toList()
      ..sort((a, b) => versionGroupRank(games[a]!.first)
          .compareTo(versionGroupRank(games[b]!.first)));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(child: ItemSprite(url: info.spriteUrl, size: 120)),
        const SizedBox(height: 8),
        Center(
          child: Text(
            machineLabel(info.name),
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: Text(
            moves.length > 1 ? 'Golpe por jogo' : 'Golpe',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        if (moves.isEmpty)
          const Text('Nenhum golpe registrado para esta máquina.'),
        for (final move in moves)
          Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(move.pretty,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(games[move]!.map(versionGroupLabel).join(' · ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MoveScreen(moveName: move)),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
      ],
    );
  }
}