import 'package:flutter/material.dart';

import '../repositories/ability_repository.dart';
import '../widgets/named_ref_list_screen.dart';
import 'ability_screen.dart';

class AbilityListScreen extends StatelessWidget {
  const AbilityListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Habilidades',
      searchable: true,
      searchHint: 'Buscar habilidade',
      emptyText: 'Nenhuma habilidade encontrada.',
      loader: AbilityRepository.instance.getList,
      leading: (r) => CircleAvatar(child: Text('${r.id}')),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AbilityScreen(idOrName: r.name)),
      ),
    );
  }
}