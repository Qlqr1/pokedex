import 'package:flutter/material.dart';

import '../models/pokemon_extra.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/stat_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/async_page.dart';
import 'nature_screen.dart';

/// Lista de naturezas, já mostrando o que cada uma aumenta e diminui.
class NatureListScreen extends StatelessWidget {
  const NatureListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AsyncPage<List<NatureInfo>>(
      title: 'Naturezas',
      errorText: 'Não foi possível carregar as naturezas.',
      loader: PokemonExtraRepository.instance.getNatures,
      builder: (context, natures) {
        final list = [...natures]..sort((a, b) => a.name.compareTo(b.name));
        return ListView.separated(
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final n = list[i];
            return ListTile(
              leading: CircleAvatar(child: Text('${n.id}')),
              title: Text(n.name.pretty),
              subtitle: Text(n.isNeutral
                  ? 'Neutra'
                  : '↑ ${statLabel(n.increased!)}   ↓ ${statLabel(n.decreased!)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => NatureScreen(natureName: n.name)),
              ),
            );
          },
        );
      },
    );
  }
}