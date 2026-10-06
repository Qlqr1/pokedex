import 'package:flutter/material.dart';

import '../repositories/pokemon_extra_repository.dart';
import '../utils/stat_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'stat_screen.dart';

class StatListScreen extends StatelessWidget {
  const StatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Status',
      searchById: false,
      emptyText: 'Nenhum status encontrado.',
      loader: PokemonExtraRepository.instance.getStats,
      label: (r) => statLabel(r.name),
      leading: (r) => CircleAvatar(child: Text('${r.id}')),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => StatScreen(statName: r.name)),
      ),
    );
  }
}