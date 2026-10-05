import 'package:flutter/material.dart';

import '../models/contest.dart';
import '../repositories/contest_repository.dart';
import 'contest_effect_screen.dart';

/// Lista de efeitos de concurso (normais ou de Super Contest).
class ContestEffectListScreen extends StatefulWidget {
  final bool superContest;
  const ContestEffectListScreen({super.key, required this.superContest});

  @override
  State<ContestEffectListScreen> createState() =>
      _ContestEffectListScreenState();
}

class _ContestEffectListScreenState extends State<ContestEffectListScreen> {
  late Future<List<ContestEffectInfo>> _future;

  Future<List<ContestEffectInfo>> _load() => widget.superContest
      ? ContestRepository.instance.getSuperContestEffects()
      : ContestRepository.instance.getContestEffects();

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.superContest
            ? 'Efeitos de Super Contest'
            : 'Efeitos de concurso'),
      ),
      body: FutureBuilder<List<ContestEffectInfo>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar os efeitos.'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: _retry, child: const Text('Tentar novamente')),
              ]),
            );
          }
          final items = snap.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum efeito encontrado.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = items[i];
              final numbers = [
                if (e.appeal != null) 'Apelo ${e.appeal}',
                if (e.jam != null) 'Jam ${e.jam}',
              ].join(' · ');
              return ListTile(
                leading: CircleAvatar(child: Text('${e.id}')),
                title: Text(
                  e.flavor ?? e.effect ?? 'Efeito #${e.id}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: numbers.isEmpty ? null : Text(numbers),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContestEffectScreen(
                        effect: e, superContest: widget.superContest),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}