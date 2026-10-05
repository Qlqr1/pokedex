import 'package:flutter/material.dart';

import '../models/encounter_info.dart';
import '../repositories/encounter_repository.dart';
import '../utils/encounter_labels.dart';
import '../widgets/info_row.dart';
import 'encounter_condition_screen.dart';

/// Página de uma condição específica (ex.: "time-night" -> Noite).
class EncounterConditionValueScreen extends StatefulWidget {
  final String valueName;
  const EncounterConditionValueScreen({super.key, required this.valueName});

  @override
  State<EncounterConditionValueScreen> createState() =>
      _EncounterConditionValueScreenState();
}

class _EncounterConditionValueScreenState
    extends State<EncounterConditionValueScreen> {
  late Future<ConditionValueInfo> _future;

  @override
  void initState() {
    super.initState();
    _future = EncounterRepository.instance.getConditionValue(widget.valueName);
  }

  void _retry() => setState(() => _future =
      EncounterRepository.instance.getConditionValue(widget.valueName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(conditionLabel(widget.valueName))),
      body: FutureBuilder<ConditionValueInfo>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar esta condição.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            );
          }
          final v = snap.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              InfoRow('Tipo de condição', conditionTypeLabel(v.condition),
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => EncounterConditionScreen(
                                conditionName: v.condition)),
                      )),
              InfoRow('Nome oficial (API)', v.displayName ?? '—'),
              InfoRow('Identificador', v.name),
              InfoRow('Número', '#${v.id}'),
            ],
          );
        },
      ),
    );
  }
}