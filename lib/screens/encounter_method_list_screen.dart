import 'package:flutter/material.dart';

import '../repositories/encounter_repository.dart';
import '../utils/encounter_labels.dart';
import '../widgets/named_ref_list_screen.dart';
import 'encounter_method_screen.dart';

class EncounterMethodListScreen extends StatelessWidget {
  const EncounterMethodListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Métodos de encontro',
      searchable: true,
      searchHint: 'Buscar método',
      searchById: false,
      emptyText: 'Nenhum método encontrado.',
      loader: EncounterRepository.instance.getMethods,
      label: (r) => methodLabel(r.name),
      leading: (_) => const Icon(Icons.hiking),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EncounterMethodScreen(methodName: r.name)),
      ),
    );
  }
}