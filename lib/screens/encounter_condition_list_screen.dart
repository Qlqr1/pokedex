import 'package:flutter/material.dart';

import '../repositories/encounter_repository.dart';
import '../utils/encounter_labels.dart';
import '../widgets/named_ref_list_screen.dart';
import 'encounter_condition_screen.dart';

/// Tipos de condição (horário, enxame, rádio...).
class EncounterConditionListScreen extends StatelessWidget {
  const EncounterConditionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Condições',
      searchById: false,
      emptyText: 'Nenhuma condição encontrada.',
      loader: EncounterRepository.instance.getConditions,
      label: (r) => conditionTypeLabel(r.name),
      leading: (_) => const Icon(Icons.tune),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EncounterConditionScreen(conditionName: r.name)),
      ),
    );
  }
}