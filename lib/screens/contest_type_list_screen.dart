import 'package:flutter/material.dart';

import '../repositories/contest_repository.dart';
import '../widgets/named_ref_list_screen.dart';
import 'contest_type_screen.dart';

class ContestTypeListScreen extends StatelessWidget {
  const ContestTypeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Tipos de concurso',
      searchById: false,
      emptyText: 'Nenhum tipo de concurso encontrado.',
      loader: ContestRepository.instance.getContestTypes,
      leading: (r) => CircleAvatar(child: Text('${r.id}')),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ContestTypeScreen(typeName: r.name)),
      ),
    );
  }
}