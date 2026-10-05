import 'package:flutter/material.dart';

import '../models/encounter_info.dart';
import '../repositories/encounter_repository.dart';
import '../utils/encounter_labels.dart';
import '../widgets/info_row.dart';

/// Página de um método de encontro.
class EncounterMethodScreen extends StatefulWidget {
  final String methodName; // ex.: "old-rod"
  const EncounterMethodScreen({super.key, required this.methodName});

  @override
  State<EncounterMethodScreen> createState() => _EncounterMethodScreenState();
}

class _EncounterMethodScreenState extends State<EncounterMethodScreen> {
  late Future<EncounterMethodInfo> _future;

  @override
  void initState() {
    super.initState();
    _future = EncounterRepository.instance.getMethod(widget.methodName);
  }

  void _retry() => setState(
      () => _future = EncounterRepository.instance.getMethod(widget.methodName));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(methodLabel(widget.methodName))),
      body: FutureBuilder<EncounterMethodInfo>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar este método.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            );
          }
          final m = snap.data!;
          final description = methodDescription(m.name);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (description != null) ...[
                Text(description),
                const SizedBox(height: 12),
              ],
              InfoRow('Nome oficial (API)', m.displayName ?? '—'),
              InfoRow('Identificador', m.name),
              InfoRow('Número', '#${m.id}'),
              InfoRow('Ordem de exibição', '${m.order}'),
            ],
          );
        },
      ),
    );
  }
}