import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/string_utils.dart';

/// Árvore evolutiva. Ramificações (ex.: Eevee) ficam lado a lado e quebram
/// de linha quando não cabem. Tocar em um estágio chama [onSelect] com o ID
/// da espécie.
class EvolutionTree extends StatelessWidget {
  final ChainLink root;
  final String currentSpecies;
  final void Function(int speciesId) onSelect;

  const EvolutionTree({
    super.key,
    required this.root,
    required this.currentSpecies,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: _subtree(context, root, null));
  }

  Widget _subtree(BuildContext context, ChainLink link, EvolutionDetail? via) {
    final isChild = via != null || link != root;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isChild) _Arrow(text: via == null ? '' : describeEvolution(via)),
        _EvolutionNode(
          species: link.species,
          isCurrent: link.species.name == currentSpecies,
          onTap: link.species.id == null
              ? null
              : () => onSelect(link.species.id!),
        ),
        if (link.evolvesTo.isNotEmpty) ...[
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 16,
            runSpacing: 16,
            children: link.evolvesTo
                .map(
                  (next) => _subtree(
                    context,
                    next,
                    next.evolutionDetails.isEmpty
                        ? null
                        : next.evolutionDetails.first,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Texto curto com as condições de uma evolução.
String describeEvolution(EvolutionDetail d) {
  final parts = <String>[];
  if (d.minLevel != null) parts.add('Nível ${d.minLevel}');
  if (d.item != null) parts.add('Usar ${d.item!.name.pretty}');
  if (d.trigger.name == 'trade') {
    parts.add(
      d.tradeSpecies != null
          ? 'Troca por ${d.tradeSpecies!.name.pretty}'
          : 'Troca',
    );
  }
  if (d.heldItem != null) parts.add('Segurando ${d.heldItem!.name.pretty}');
  if (d.knownMove != null) parts.add('Sabendo ${d.knownMove!.name.pretty}');
  if (d.knownMoveType != null) {
    parts.add('Golpe do tipo ${d.knownMoveType!.name.pretty}');
  }
  if (d.location != null) parts.add('Em ${d.location!.name.pretty}');
  if (d.minHappiness != null) parts.add('Felicidade ${d.minHappiness}');
  if (d.minAffection != null) parts.add('Afeto ${d.minAffection}');
  if (d.minBeauty != null) parts.add('Beleza ${d.minBeauty}');
  if (d.gender == 1) parts.add('Fêmea');
  if (d.gender == 2) parts.add('Macho');
  if (d.timeOfDay == 'day') parts.add('De dia');
  if (d.timeOfDay == 'night') parts.add('De noite');
  if (d.timeOfDay == 'dusk') parts.add('Ao entardecer');
  if (d.needsOverworldRain) parts.add('Com chuva');
  if (d.turnUpsideDown) parts.add('Console de cabeça para baixo');
  if (d.partySpecies != null) {
    parts.add('Com ${d.partySpecies!.name.pretty} no time');
  }
  if (d.partyType != null) {
    parts.add('Com tipo ${d.partyType!.name.pretty} no time');
  }
  if (d.relativePhysicalStats == 1) parts.add('Ataque > Defesa');
  if (d.relativePhysicalStats == -1) parts.add('Ataque < Defesa');
  if (d.relativePhysicalStats == 0) parts.add('Ataque = Defesa');

  if (parts.isEmpty) return d.trigger.name.pretty;
  return parts.join(' · ');
}

class _Arrow extends StatelessWidget {
  final String text;

  const _Arrow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          const Icon(Icons.arrow_downward, size: 18),
          if (text.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }
}

class _EvolutionNode extends StatelessWidget {
  final NamedApiResource species;
  final bool isCurrent;
  final VoidCallback? onTap;

  const _EvolutionNode({
    required this.species,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final id = species.id;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: isCurrent
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.grey.shade200,
              backgroundImage: id == null
                  ? null
                  : NetworkImage(
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$id.png',
                    ),
              child: id == null ? const Icon(Icons.catching_pokemon) : null,
            ),
            const SizedBox(height: 4),
            Text(
              species.name.pretty,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
