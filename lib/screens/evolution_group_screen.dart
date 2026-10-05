import 'package:flutter/material.dart';

import 'evolution_trigger_list_screen.dart';
import 'evolution_variable_list_screen.dart';

/// Grupo Evolution: variáveis (condições) e gatilhos (triggers).
class EvolutionGroupScreen extends StatelessWidget {
  const EvolutionGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String title, String subtitle, Widget screen) {
      return Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ),
          ),
          const Divider(height: 1),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Evolution')),
      body: ListView(
        children: [
          item(Icons.tune, 'Variáveis',
              'Condições que uma evolução pode exigir',
              const EvolutionVariableListScreen()),
          item(Icons.bolt, 'Gatilhos (Triggers)',
              'O que dispara a evolução',
              const EvolutionTriggerListScreen()),
        ],
      ),
    );
  }
}