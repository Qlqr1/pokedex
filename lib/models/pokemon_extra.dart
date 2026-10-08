import '../utils/lang.dart';
import 'named_ref.dart';

String? _en(List list, String key) => Lang.pick(list, key);

List<String> _names(dynamic l) =>
    ((l ?? []) as List).map((e) => e['name'] as String).toList();

/// Nome + variação (ex.: golpe "swords-dance" +2, natureza "adamant" +2).
class NameChange {
  final String name;
  final int change;
  const NameChange(this.name, this.change);
}

class TypeInfo {
  final int id;
  final String name;
  final String? generation;
  final String? damageClass;
  final Map<String, List<String>> relations;
  final List<NamedRef> pokemon;
  final List<String> moves;

  const TypeInfo({
    required this.id,
    required this.name,
    required this.generation,
    required this.damageClass,
    required this.relations,
    required this.pokemon,
    required this.moves,
  });

  factory TypeInfo.fromJson(Map<String, dynamic> j) {
    final rel = j['damage_relations'] as Map<String, dynamic>;
    return TypeInfo(
      id: j['id'],
      name: j['name'],
      generation: j['generation']?['name'],
      damageClass: j['move_damage_class']?['name'],
      relations: {for (final k in rel.keys) k: _names(rel[k])},
      pokemon: (j['pokemon'] as List)
          .map((e) => NamedRef.fromJson(e['pokemon']))
          .toList(),
      moves: _names(j['moves']),
    );
  }
}

class StatInfo {
  final int id;
  final String name;
  final bool isBattleOnly;
  final String? damageClass;
  final List<NameChange> increaseMoves;
  final List<NameChange> decreaseMoves;
  final List<String> increaseNatures;
  final List<String> decreaseNatures;

  const StatInfo({
    required this.id,
    required this.name,
    required this.isBattleOnly,
    required this.damageClass,
    required this.increaseMoves,
    required this.decreaseMoves,
    required this.increaseNatures,
    required this.decreaseNatures,
  });

  static List<NameChange> _moves(dynamic l) => ((l ?? []) as List)
      .map((e) => NameChange(e['move']['name'], e['change']))
      .toList();

  factory StatInfo.fromJson(Map<String, dynamic> j) {
    final moves = j['affecting_moves'] as Map<String, dynamic>;
    final natures = j['affecting_natures'] as Map<String, dynamic>;
    return StatInfo(
      id: j['id'],
      name: j['name'],
      isBattleOnly: j['is_battle_only'] ?? false,
      damageClass: j['move_damage_class']?['name'],
      increaseMoves: _moves(moves['increase']),
      decreaseMoves: _moves(moves['decrease']),
      increaseNatures: _names(natures['increase']),
      decreaseNatures: _names(natures['decrease']),
    );
  }
}

class BattleStylePref {
  final String style; // attack, defense, support
  final int lowHp;
  final int highHp;
  const BattleStylePref(this.style, this.lowHp, this.highHp);
}

class NatureInfo {
  final int id;
  final String name;
  final String? increased;
  final String? decreased;
  final String? likes;
  final String? hates;
  final List<NameChange> pokeathlon;
  final List<BattleStylePref> styles;

  const NatureInfo({
    required this.id,
    required this.name,
    required this.increased,
    required this.decreased,
    required this.likes,
    required this.hates,
    required this.pokeathlon,
    required this.styles,
  });

  bool get isNeutral => increased == null || decreased == null;

  factory NatureInfo.fromJson(Map<String, dynamic> j) => NatureInfo(
        id: j['id'],
        name: j['name'],
        increased: j['increased_stat']?['name'],
        decreased: j['decreased_stat']?['name'],
        likes: j['likes_flavor']?['name'],
        hates: j['hates_flavor']?['name'],
        pokeathlon: ((j['pokeathlon_stat_changes'] ?? []) as List)
            .map((e) => NameChange(e['pokeathlon_stat']['name'], e['max_change']))
            .toList(),
        styles: ((j['move_battle_style_preferences'] ?? []) as List)
            .map((e) => BattleStylePref(
                  e['move_battle_style']['name'],
                  e['low_hp_preference'],
                  e['high_hp_preference'],
                ))
            .toList(),
      );
}

class CharacteristicInfo {
  final int id;
  final int geneModulo;
  final List<int> possibleValues;
  final String? highestStat;
  final String? description;

  const CharacteristicInfo({
    required this.id,
    required this.geneModulo,
    required this.possibleValues,
    required this.highestStat,
    required this.description,
  });

  factory CharacteristicInfo.fromJson(Map<String, dynamic> j) =>
      CharacteristicInfo(
        id: j['id'],
        geneModulo: j['gene_modulo'],
        possibleValues:
            (j['possible_values'] as List).map((e) => e as int).toList(),
        highestStat: j['highest_stat']?['name'],
        description: _en((j['descriptions'] ?? []) as List, 'description'),
      );
}

/// Grupo de ovo ou habitat: um nome e as espécies que pertencem a ele.
class SpeciesGroup {
  final int id;
  final String name;
  final List<NamedRef> species;
  const SpeciesGroup(
      {required this.id, required this.name, required this.species});

  factory SpeciesGroup.fromJson(Map<String, dynamic> j) => SpeciesGroup(
        id: j['id'],
        name: j['name'],
        species: (j['pokemon_species'] as List)
            .map((e) => NamedRef.fromJson(e))
            .toList(),
      );
}

class PokeathlonStatInfo {
  final int id;
  final String name;
  final List<NameChange> increase; // natureza + variação máxima
  final List<NameChange> decrease;
  const PokeathlonStatInfo({
    required this.id,
    required this.name,
    required this.increase,
    required this.decrease,
  });

  static List<NameChange> _list(dynamic l) => ((l ?? []) as List)
      .map((e) => NameChange(e['nature']['name'], e['max_change']))
      .toList();

  factory PokeathlonStatInfo.fromJson(Map<String, dynamic> j) {
    final n = j['affecting_natures'] as Map<String, dynamic>;
    return PokeathlonStatInfo(
      id: j['id'],
      name: j['name'],
      increase: _list(n['increase']),
      decrease: _list(n['decrease']),
    );
  }
}
