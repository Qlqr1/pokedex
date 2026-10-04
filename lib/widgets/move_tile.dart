import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/pokemon_repository.dart';
import '../utils/string_utils.dart';
import 'type_badge.dart';

String damageClassLabel(String? name) {
  switch (name) {
    case 'physical':
      return 'Físico';
    case 'special':
      return 'Especial';
    case 'status':
      return 'Status';
    default:
      return name?.pretty ?? '—';
  }
}

/// Item de golpe usado na lista de golpes e na aba "Golpes" do Pokémon.
/// Mostra o nome na hora e carrega tipo, poder, precisão e PP só quando o
/// item aparece na tela (o repository guarda em cache).
class MoveTile extends StatefulWidget {
  final String moveName;

  /// Texto à esquerda (ex.: "Nv. 13" ou "#33"). Opcional.
  final String? leading;
  final VoidCallback? onTap;

  const MoveTile({
    super.key,
    required this.moveName,
    this.leading,
    this.onTap,
  });

  @override
  State<MoveTile> createState() => _MoveTileState();
}

class _MoveTileState extends State<MoveTile> {
  late Future<Move> _future;

  @override
  void initState() {
    super.initState();
    _future = PokemonRepository.shared.getMove(widget.moveName);
  }

  @override
  void didUpdateWidget(covariant MoveTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moveName != widget.moveName) {
      _future = PokemonRepository.shared.getMove(widget.moveName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grey = Colors.grey.shade600;

    return ListTile(
      onTap: widget.onTap,
      leading: widget.leading == null
          ? null
          : SizedBox(
              width: 48,
              child: Center(
                child: Text(
                  widget.leading!,
                  style: TextStyle(fontSize: 12, color: grey),
                ),
              ),
            ),
      title: Text(
        widget.moveName.pretty,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: FutureBuilder<Move>(
        future: _future,
        builder: (context, snapshot) {
          final move = snapshot.data;
          if (move == null) {
            return Text(
              snapshot.hasError ? '—' : 'Carregando…',
              style: TextStyle(fontSize: 12, color: grey),
            );
          }
          final accuracy = move.accuracy != null ? '${move.accuracy}%' : '—';
          return Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                TypeBadge(type: move.type.name),
                Text(
                  '${damageClassLabel(move.damageClass?.name)} · '
                  'Poder ${move.power ?? '—'} · Prec. $accuracy · '
                  'PP ${move.pp ?? '—'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}