import 'package:flutter/material.dart';

import '../screens/encounter_condition_value_screen.dart';
import '../utils/encounter_labels.dart';

/// Abre a página da condição. Se o encontro depende de mais de uma condição
/// ao mesmo tempo (ex.: "Dia + Sem enxame"), deixa escolher qual abrir.
void openConditions(BuildContext context, List<String> names) {
  final navigator = Navigator.of(context);
  void open(String n) => navigator.push(MaterialPageRoute(
      builder: (_) => EncounterConditionValueScreen(valueName: n)));

  if (names.length == 1) {
    open(names.first);
    return;
  }
  showModalBottomSheet(
    context: context,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final n in names)
            ListTile(
              title: Text(conditionLabel(n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(sheet);
                open(n);
              },
            ),
        ],
      ),
    ),
  );
}