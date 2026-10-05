import 'package:flutter/material.dart';

import '../utils/evolution_variables.dart';
import 'evolution_variable_screen.dart';

/// Lista das variáveis (condições) de evolução.
class EvolutionVariableListScreen extends StatelessWidget {
  const EvolutionVariableListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Variáveis de evolução')),
      body: ListView.separated(
        itemCount: evolutionVariables.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final v = evolutionVariables[i];
          return ListTile(
            leading: const Icon(Icons.tune),
            title: Text(v.title),
            subtitle: Text(v.key),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EvolutionVariableScreen(variable: v)),
            ),
          );
        },
      ),
    );
  }
}