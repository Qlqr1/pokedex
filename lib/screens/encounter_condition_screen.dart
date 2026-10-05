import 'package:flutter/material.dart';

import '../repositories/encounter_repository.dart';
import '../utils/encounter_labels.dart';
import '../widgets/named_ref_list_screen.dart';
import 'encounter_condition_value_screen.dart';

/// Um tipo de condição e a lista dos seus valores (ex.: Horário -> Manhã,
/// Dia, Noite).
class EncounterConditionScreen extends StatelessWidget {
  final String conditionName; // ex.: "time"
  const EncounterConditionScreen({super.key, required this.conditionName});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: conditionTypeLabel(conditionName),
      searchById: false,
      emptyText: 'Nenhum valor registrado para esta condição.',
      loader: () async =>
          (await EncounterRepository.instance.getCondition(conditionName))
              .values,
      label: (r) => conditionLabel(r.name),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EncounterConditionValueScreen(valueName: r.name)),
      ),
    );
  }
}