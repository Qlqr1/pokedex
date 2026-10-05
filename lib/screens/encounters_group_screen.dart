import 'package:flutter/material.dart';

import 'encounter_condition_list_screen.dart';
import 'encounter_method_list_screen.dart';

/// Grupo Encounters: métodos de encontro e condições.
class EncountersGroupScreen extends StatelessWidget {
  const EncountersGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encounters')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.hiking),
            title: const Text('Métodos de encontro'),
            subtitle: const Text('Andar, pescar, surfar, presente...'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const EncounterMethodListScreen()),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.tune),
            title: const Text('Condições'),
            subtitle: const Text('Horário, enxame, rádio, estação...'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const EncounterConditionListScreen()),
            ),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}