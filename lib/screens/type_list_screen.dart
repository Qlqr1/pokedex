import 'package:flutter/material.dart';

import '../models/named_ref.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../widgets/type_badge.dart';
import 'type_screen.dart';

/// Lista de tipos, como selos clicáveis.
class TypeListScreen extends StatefulWidget {
  const TypeListScreen({super.key});

  @override
  State<TypeListScreen> createState() => _TypeListScreenState();
}

class _TypeListScreenState extends State<TypeListScreen> {
  late Future<List<NamedRef>> _future;

  @override
  void initState() {
    super.initState();
    _future = PokemonExtraRepository.instance.getTypes();
  }

  void _retry() => setState(
      () => _future = PokemonExtraRepository.instance.getTypes());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tipos')),
      body: FutureBuilder<List<NamedRef>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar os tipos.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in snap.data!)
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => TypeScreen(typeName: t.name)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: TypeBadge(type: t.name),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}