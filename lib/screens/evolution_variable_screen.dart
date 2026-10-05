import 'package:flutter/material.dart';

import '../utils/evolution_variables.dart';
import '../widgets/info_row.dart';
import 'evolution_trigger_list_screen.dart';

/// Página de uma variável de evolução.
class EvolutionVariableScreen extends StatelessWidget {
  final EvolutionVariable variable;
  const EvolutionVariableScreen({super.key, required this.variable});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: Text(variable.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InfoRow('Campo na API', variable.key),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text('O que é', style: titleStyle),
          ),
          Text(variable.description),
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 8),
            child: Text('Exemplo', style: titleStyle),
          ),
          Text(variable.example),
          if (variable.key == 'trigger') ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              icon: const Icon(Icons.bolt),
              label: const Text('Ver gatilhos'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EvolutionTriggerListScreen()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}