import 'named_api_resource.dart';
import 'shared.dart';

/// /move/{id ou nome}
class Move {
  final int id;
  final String name;
  final int? accuracy;
  final int? effectChance;
  final int? pp;
  final int priority;
  final int? power;
  final NamedApiResource? damageClass;
  final NamedApiResource type;
  final NamedApiResource? target;
  final NamedApiResource? generation;
  final List<LocalizedName> names;
  final List<VerboseEffect> effectEntries;
  final List<MoveStatChange> statChanges;
  final List<NamedApiResource> learnedByPokemon;

  const Move({
    required this.id,
    required this.name,
    required this.accuracy,
    required this.effectChance,
    required this.pp,
    required this.priority,
    required this.power,
    required this.damageClass,
    required this.type,
    required this.target,
    required this.generation,
    required this.names,
    required this.effectEntries,
    required this.statChanges,
    required this.learnedByPokemon,
  });

  factory Move.fromJson(Map<String, dynamic> json) => Move(
        id: json['id'] as int,
        name: json['name'] as String,
        accuracy: json['accuracy'] as int?,
        effectChance: json['effect_chance'] as int?,
        pp: json['pp'] as int?,
        priority: json['priority'] as int? ?? 0,
        power: json['power'] as int?,
        damageClass: parseNamed(json['damage_class']),
        type: NamedApiResource.fromJson(json['type'] as Map<String, dynamic>),
        target: parseNamed(json['target']),
        generation: parseNamed(json['generation']),
        names: parseList(json['names'], LocalizedName.fromJson),
        effectEntries: parseList(json['effect_entries'], VerboseEffect.fromJson),
        statChanges: parseList(json['stat_changes'], MoveStatChange.fromJson),
        learnedByPokemon:
            parseList(json['learned_by_pokemon'], NamedApiResource.fromJson),
      );
}

class MoveStatChange {
  final int change;
  final NamedApiResource stat;

  const MoveStatChange({required this.change, required this.stat});

  factory MoveStatChange.fromJson(Map<String, dynamic> json) => MoveStatChange(
        change: json['change'] as int? ?? 0,
        stat: NamedApiResource.fromJson(json['stat'] as Map<String, dynamic>),
      );
}
