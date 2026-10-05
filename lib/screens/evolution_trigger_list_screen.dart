import 'package:flutter/material.dart';

import '../repositories/evolution_repository.dart';
import '../utils/evolution_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'evolution_trigger_screen.dart';

class EvolutionTriggerListScreen extends StatelessWidget {
  const EvolutionTriggerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Gatilhos de evolução',
      searchById: false,
      emptyText: 'Nenhum gatilho encontrado.',
      loader: EvolutionRepository.instance.getTriggers,
      label: (r) => triggerLabel(r.name),
      leading: (_) => const Icon(Icons.bolt),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => EvolutionTriggerScreen(triggerName: r.name)),
      ),
    );
  }
}