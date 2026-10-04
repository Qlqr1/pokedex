import 'named_api_resource.dart';
import 'shared.dart';

/// /pokemon-species/{id ou nome}
class PokemonSpecies {
  final int id;
  final String name;
  final int order;
  final int genderRate; // -1 = sem gênero; senão, chance de fêmea em oitavos
  final int? captureRate;
  final int? baseHappiness;
  final bool isBaby;
  final bool isLegendary;
  final bool isMythical;
  final int? hatchCounter;
  final bool hasGenderDifferences;
  final bool formsSwitchable;
  final NamedApiResource? growthRate;
  final NamedApiResource? color;
  final NamedApiResource? shape;
  final NamedApiResource? habitat;
  final NamedApiResource generation;
  final NamedApiResource? evolvesFromSpecies;
  final ApiResource? evolutionChain;
  final List<NamedApiResource> eggGroups;
  final List<LocalizedName> names;
  final List<FlavorText> flavorTextEntries;
  final List<Genus> genera;
  final List<SpeciesVariety> varieties;

  const PokemonSpecies({
    required this.id,
    required this.name,
    required this.order,
    required this.genderRate,
    required this.captureRate,
    required this.baseHappiness,
    required this.isBaby,
    required this.isLegendary,
    required this.isMythical,
    required this.hatchCounter,
    required this.hasGenderDifferences,
    required this.formsSwitchable,
    required this.growthRate,
    required this.color,
    required this.shape,
    required this.habitat,
    required this.generation,
    required this.evolvesFromSpecies,
    required this.evolutionChain,
    required this.eggGroups,
    required this.names,
    required this.flavorTextEntries,
    required this.genera,
    required this.varieties,
  });

  factory PokemonSpecies.fromJson(Map<String, dynamic> json) =>
      PokemonSpecies(
        id: json['id'] as int,
        name: json['name'] as String,
        order: json['order'] as int? ?? 0,
        genderRate: json['gender_rate'] as int? ?? -1,
        captureRate: json['capture_rate'] as int?,
        baseHappiness: json['base_happiness'] as int?,
        isBaby: json['is_baby'] as bool? ?? false,
        isLegendary: json['is_legendary'] as bool? ?? false,
        isMythical: json['is_mythical'] as bool? ?? false,
        hatchCounter: json['hatch_counter'] as int?,
        hasGenderDifferences: json['has_gender_differences'] as bool? ?? false,
        formsSwitchable: json['forms_switchable'] as bool? ?? false,
        growthRate: parseNamed(json['growth_rate']),
        color: parseNamed(json['color']),
        shape: parseNamed(json['shape']),
        habitat: parseNamed(json['habitat']),
        generation: NamedApiResource.fromJson(
            json['generation'] as Map<String, dynamic>),
        evolvesFromSpecies: parseNamed(json['evolves_from_species']),
        evolutionChain: parseApi(json['evolution_chain']),
        eggGroups: parseList(json['egg_groups'], NamedApiResource.fromJson),
        names: parseList(json['names'], LocalizedName.fromJson),
        flavorTextEntries:
            parseList(json['flavor_text_entries'], FlavorText.fromJson),
        genera: parseList(json['genera'], Genus.fromJson),
        varieties: parseList(json['varieties'], SpeciesVariety.fromJson),
      );

  /// Última descrição da Pokédex no idioma pedido.
  String? flavorTextIn(String languageCode) {
    for (final entry in flavorTextEntries.reversed) {
      if (entry.language.name == languageCode) return entry.text;
    }
    return null;
  }

  /// Categoria (ex.: "Seed Pokémon") no idioma pedido.
  String? genusIn(String languageCode) {
    for (final g in genera) {
      if (g.language.name == languageCode) return g.genus;
    }
    return null;
  }
}

class Genus {
  final String genus;
  final NamedApiResource language;

  const Genus({required this.genus, required this.language});

  factory Genus.fromJson(Map<String, dynamic> json) => Genus(
        genus: json['genus'] as String? ?? '',
        language: NamedApiResource.fromJson(
            json['language'] as Map<String, dynamic>),
      );
}

class SpeciesVariety {
  final bool isDefault;
  final NamedApiResource pokemon;

  const SpeciesVariety({required this.isDefault, required this.pokemon});

  factory SpeciesVariety.fromJson(Map<String, dynamic> json) =>
      SpeciesVariety(
        isDefault: json['is_default'] as bool? ?? false,
        pokemon: NamedApiResource.fromJson(
            json['pokemon'] as Map<String, dynamic>),
      );
}
