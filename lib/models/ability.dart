import '../utils/lang.dart';
import 'named_ref.dart';
export 'named_ref.dart';

class AbilityPokemon {
  final NamedRef pokemon;
  final bool isHidden;
  final int slot;
  const AbilityPokemon(
      {required this.pokemon, required this.isHidden, required this.slot});

  factory AbilityPokemon.fromJson(Map<String, dynamic> j) => AbilityPokemon(
        pokemon: NamedRef.fromJson(j['pokemon']),
        isHidden: j['is_hidden'] as bool,
        slot: j['slot'] as int,
      );

  String get spriteUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${pokemon.id}.png';
}

class Ability {
  final int id;
  final String name;
  final bool isMainSeries;
  final String generation;
  final String? displayName;
  final String? effect;
  final String? shortEffect;
  final String? flavorText;
  final List<AbilityPokemon> pokemon;

  const Ability({
    required this.id,
    required this.name,
    required this.isMainSeries,
    required this.generation,
    this.displayName,
    this.effect,
    this.shortEffect,
    this.flavorText,
    this.pokemon = const [],
  });

  static String? _en(List list, String key) => Lang.pick(list, key);

  factory Ability.fromJson(Map<String, dynamic> j) => Ability(
        id: j['id'] as int,
        name: j['name'] as String,
        isMainSeries: j['is_main_series'] as bool,
        generation: (j['generation']?['name'] ?? '') as String,
        displayName: _en(j['names'] as List, 'name'),
        effect: _en(j['effect_entries'] as List, 'effect'),
        shortEffect: _en(j['effect_entries'] as List, 'short_effect'),
        flavorText: _en((j['flavor_text_entries'] as List).reversed.toList(),
            'flavor_text'),
        pokemon: (j['pokemon'] as List)
            .map((e) => AbilityPokemon.fromJson(e))
            .toList(),
      );
}
