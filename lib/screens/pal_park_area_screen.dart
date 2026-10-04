import 'package:flutter/material.dart';

import '../models/location.dart';
import '../repositories/location_repository.dart';
import '../utils/string_utils.dart';
import '../widgets/open_pokemon.dart';

/// Área do Pal Park: Pokémon que aparecem, com pontuação base e taxa.
class PalParkAreaScreen extends StatefulWidget {
  final String areaName;
  const PalParkAreaScreen({super.key, required this.areaName});

  @override
  State<PalParkAreaScreen> createState() => _PalParkAreaScreenState();
}

class _PalParkAreaScreenState extends State<PalParkAreaScreen> {
  late Future<PalParkArea> _future;

  @override
  void initState() {
    super.initState();
    _future = LocationRepository.instance.getPalParkArea(widget.areaName);
  }

  void _retry() => setState(() {
        _future = LocationRepository.instance.getPalParkArea(widget.areaName);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.areaName.pretty)),
      body: FutureBuilder<PalParkArea>(
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
          final list = [...snap.data!.encounters]
            ..sort((a, b) => b.rate.compareTo(a.rate));
          if (list.isEmpty) {
            return const Center(child: Text('Nenhum Pokémon nesta área.'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final e = list[i];
              return ListTile(
                title: Text(e.species.name.pretty),
                subtitle: Text(
                    'Taxa: ${e.rate}% · Pontuação base: ${e.baseScore}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => openPokemon(context, e.species.id),
              );
            },
          );
        },
      ),
    );
  }
}