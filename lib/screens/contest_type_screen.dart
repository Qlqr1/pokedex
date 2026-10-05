import 'package:flutter/material.dart';

import '../models/contest.dart';
import '../repositories/contest_repository.dart';
import '../utils/berry_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/info_row.dart';
import 'berry_screen.dart';

/// Página de um tipo de concurso: cor, sabor de berry associado e as berries
/// com esse sabor.
class ContestTypeScreen extends StatefulWidget {
  final String typeName; // ex.: "cool"
  const ContestTypeScreen({super.key, required this.typeName});

  @override
  State<ContestTypeScreen> createState() => _ContestTypeScreenState();
}

class _ContestTypeScreenState extends State<ContestTypeScreen> {
  static const _colors = {
    'Red': ('Vermelho', Colors.red),
    'Blue': ('Azul', Colors.blue),
    'Pink': ('Rosa', Colors.pink),
    'Green': ('Verde', Colors.green),
    'Yellow': ('Amarelo', Colors.amber),
  };

  late Future<ContestTypeInfo> _future;

  @override
  void initState() {
    super.initState();
    _future = ContestRepository.instance.getContestType(widget.typeName);
  }

  void _retry() => setState(() =>
      _future = ContestRepository.instance.getContestType(widget.typeName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.typeName.pretty)),
      body: FutureBuilder<ContestTypeInfo>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar este tipo de concurso.'),
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

  Widget _content(ContestTypeInfo t) {
    final colorInfo = t.color == null ? null : _colors[t.color];
    final flavor = t.berryFlavor;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (colorInfo != null)
          Center(
            child: CircleAvatar(radius: 36, backgroundColor: colorInfo.$2),
          ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            t.name.pretty,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        InfoRow('Número', '#${t.id}'),
        InfoRow('Cor', colorInfo?.$1 ?? t.color ?? '—'),
        InfoRow('Sabor de berry', flavor == null ? '—' : flavorLabel(flavor)),
        if (flavor != null) _FlavorBerries(flavor: flavor),
      ],
    );
  }
}

/// Berries com o sabor do tipo de concurso, da mais potente para a menos.
class _FlavorBerries extends StatelessWidget {
  final String flavor;
  const _FlavorBerries({required this.flavor});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlavorBerry>>(
      future: ContestRepository.instance.getFlavorBerries(flavor),
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (snap.hasError) return const SizedBox.shrink();
        final berries = snap.data!.where((b) => b.potency > 0).toList();
        if (berries.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(
                'Berries com este sabor (${berries.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final b in berries)
                  ActionChip(
                    label: Text('${berryLabel(b.name)} ${b.potency}'),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BerryScreen(berryName: b.name)),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}