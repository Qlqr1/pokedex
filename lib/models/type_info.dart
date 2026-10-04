import 'named_api_resource.dart';
import 'shared.dart';

/// /type/{id ou nome}
/// Chamado TypeInfo para não conflitar com a classe `Type` do dart:core.
class TypeInfo {
  final int id;
  final String name;
  final NamedApiResource? generation;
  final NamedApiResource? moveDamageClass;
  final TypeRelations damageRelations;
  final List<LocalizedName> names;
  final List<TypePokemon> pokemon;
  final List<NamedApiResource> moves;

  const TypeInfo({
    required this.id,
    required this.name,
    required this.generation,
    required this.moveDamageClass,
    required this.damageRelations,
    required this.names,
    required this.pokemon,
    required this.moves,
  });

  factory TypeInfo.fromJson(Map<String, dynamic> json) => TypeInfo(
        id: json['id'] as int,
        name: json['name'] as String,
        generation: parseNamed(json['generation']),
        moveDamageClass: parseNamed(json['move_damage_class']),
        damageRelations: TypeRelations.fromJson(
            json['damage_relations'] as Map<String, dynamic>? ?? {}),
        names: parseList(json['names'], LocalizedName.fromJson),
        pokemon: parseList(json['pokemon'], TypePokemon.fromJson),
        moves: parseList(json['moves'], NamedApiResource.fromJson),
      );
}

/// Relações de dano: base para fraquezas, resistências e imunidades.
class TypeRelations {
  final List<NamedApiResource> noDamageTo;
  final List<NamedApiResource> halfDamageTo;
  final List<NamedApiResource> doubleDamageTo;
  final List<NamedApiResource> noDamageFrom;
  final List<NamedApiResource> halfDamageFrom;
  final List<NamedApiResource> doubleDamageFrom;

  const TypeRelations({
    required this.noDamageTo,
    required this.halfDamageTo,
    required this.doubleDamageTo,
    required this.noDamageFrom,
    required this.halfDamageFrom,
    required this.doubleDamageFrom,
  });

  factory TypeRelations.fromJson(Map<String, dynamic> json) {
    List<NamedApiResource> l(String key) =>
        parseList(json[key], NamedApiResource.fromJson);
    return TypeRelations(
      noDamageTo: l('no_damage_to'),
      halfDamageTo: l('half_damage_to'),
      doubleDamageTo: l('double_damage_to'),
      noDamageFrom: l('no_damage_from'),
      halfDamageFrom: l('half_damage_from'),
      doubleDamageFrom: l('double_damage_from'),
    );
  }
}

class TypePokemon {
  final int slot;
  final NamedApiResource pokemon;

  const TypePokemon({required this.slot, required this.pokemon});

  factory TypePokemon.fromJson(Map<String, dynamic> json) => TypePokemon(
        slot: json['slot'] as int? ?? 0,
        pokemon:
            NamedApiResource.fromJson(json['pokemon'] as Map<String, dynamic>),
      );
}

/// Cálculo de fraquezas/resistências/imunidades para um ou dois tipos.
/// Retorna multiplicador por tipo atacante (0, 0.25, 0.5, 1, 2, 4).
Map<String, double> calculateDefense(List<TypeInfo> defendingTypes) {
  final result = <String, double>{};
  for (final t in defendingTypes) {
    final r = t.damageRelations;
    for (final x in r.doubleDamageFrom) {
      result[x.name] = (result[x.name] ?? 1) * 2;
    }
    for (final x in r.halfDamageFrom) {
      result[x.name] = (result[x.name] ?? 1) * 0.5;
    }
    for (final x in r.noDamageFrom) {
      result[x.name] = 0;
    }
  }
  return result;
}
