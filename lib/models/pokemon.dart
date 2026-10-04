import 'named_api_resource.dart';
import 'pokemon_ability.dart';
import 'pokemon_move.dart';
import 'pokemon_sprites.dart';
import 'pokemon_stat.dart';
import 'pokemon_type.dart';

/// Modelo principal: /pokemon/{id ou nome}
class Pokemon {
  final int id;
  final String name;
  final int? baseExperience;
  final int height; // decímetros
  final int weight; // hectogramas
  final bool isDefault;
  final int order;
  final List<PokemonAbility> abilities;
  final List<NamedApiResource> forms;
  final List<NamedApiResource> heldItems;
  final List<PokemonMove> moves;
  final NamedApiResource species;
  final PokemonSprites sprites;
  final List<PokemonStat> stats;
  final List<PokemonType> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.baseExperience,
    required this.height,
    required this.weight,
    required this.isDefault,
    required this.order,
    required this.abilities,
    required this.forms,
    required this.heldItems,
    required this.moves,
    required this.species,
    required this.sprites,
    required this.stats,
    required this.types,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) => Pokemon(
        id: json['id'] as int,
        name: json['name'] as String,
        baseExperience: json['base_experience'] as int?,
        height: json['height'] as int? ?? 0,
        weight: json['weight'] as int? ?? 0,
        isDefault: json['is_default'] as bool? ?? true,
        order: json['order'] as int? ?? 0,
        abilities: parseList(json['abilities'], PokemonAbility.fromJson),
        forms: parseList(json['forms'], NamedApiResource.fromJson),
        heldItems: (json['held_items'] as List<dynamic>? ?? [])
            .map((e) => NamedApiResource.fromJson(
                (e as Map<String, dynamic>)['item'] as Map<String, dynamic>))
            .toList(),
        moves: parseList(json['moves'], PokemonMove.fromJson),
        species: NamedApiResource.fromJson(
            json['species'] as Map<String, dynamic>),
        sprites: PokemonSprites.fromJson(
            json['sprites'] as Map<String, dynamic>? ?? {}),
        stats: parseList(json['stats'], PokemonStat.fromJson),
        types: parseList(json['types'], PokemonType.fromJson),
      );

  // ----- Conveniências para a UI -----

  /// "bulbasaur" -> "Bulbasaur"
  String get displayName =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  double get heightInMeters => height / 10;
  double get weightInKg => weight / 10;

  /// Nomes dos tipos ordenados por slot (ex.: ["grass", "poison"]).
  List<String> get typeNames =>
      (List.of(types)..sort((a, b) => a.slot.compareTo(b.slot)))
          .map((t) => t.type.name)
          .toList();
}
