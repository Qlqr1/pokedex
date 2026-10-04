import 'named_api_resource.dart';

/// Um item da lista retornada por /pokemon/{id ou nome}/encounters
class PokemonEncounter {
  final NamedApiResource locationArea;
  final List<VersionEncounterDetail> versionDetails;

  const PokemonEncounter({
    required this.locationArea,
    required this.versionDetails,
  });

  factory PokemonEncounter.fromJson(Map<String, dynamic> json) =>
      PokemonEncounter(
        locationArea: NamedApiResource.fromJson(
            json['location_area'] as Map<String, dynamic>),
        versionDetails:
            parseList(json['version_details'], VersionEncounterDetail.fromJson),
      );
}

class VersionEncounterDetail {
  final int maxChance;
  final NamedApiResource version;
  final List<EncounterDetail> encounterDetails;

  const VersionEncounterDetail({
    required this.maxChance,
    required this.version,
    required this.encounterDetails,
  });

  factory VersionEncounterDetail.fromJson(Map<String, dynamic> json) =>
      VersionEncounterDetail(
        maxChance: json['max_chance'] as int? ?? 0,
        version:
            NamedApiResource.fromJson(json['version'] as Map<String, dynamic>),
        encounterDetails:
            parseList(json['encounter_details'], EncounterDetail.fromJson),
      );
}

class EncounterDetail {
  final int minLevel;
  final int maxLevel;
  final int chance;
  final NamedApiResource method;
  final List<NamedApiResource> conditionValues;

  const EncounterDetail({
    required this.minLevel,
    required this.maxLevel,
    required this.chance,
    required this.method,
    required this.conditionValues,
  });

  factory EncounterDetail.fromJson(Map<String, dynamic> json) =>
      EncounterDetail(
        minLevel: json['min_level'] as int? ?? 0,
        maxLevel: json['max_level'] as int? ?? 0,
        chance: json['chance'] as int? ?? 0,
        method:
            NamedApiResource.fromJson(json['method'] as Map<String, dynamic>),
        conditionValues:
            parseList(json['condition_values'], NamedApiResource.fromJson),
      );
}
