import 'named_api_resource.dart';

/// Condições necessárias para uma evolução.
class EvolutionDetail {
  final NamedApiResource? item;
  final NamedApiResource trigger;
  final int? gender; // 1 = fêmea, 2 = macho
  final NamedApiResource? heldItem;
  final NamedApiResource? knownMove;
  final NamedApiResource? knownMoveType;
  final NamedApiResource? location;
  final int? minLevel;
  final int? minHappiness;
  final int? minBeauty;
  final int? minAffection;
  final bool needsOverworldRain;
  final NamedApiResource? partySpecies;
  final NamedApiResource? partyType;
  final int? relativePhysicalStats;
  final String timeOfDay; // "", "day" ou "night"
  final NamedApiResource? tradeSpecies;
  final bool turnUpsideDown;

  const EvolutionDetail({
    required this.item,
    required this.trigger,
    required this.gender,
    required this.heldItem,
    required this.knownMove,
    required this.knownMoveType,
    required this.location,
    required this.minLevel,
    required this.minHappiness,
    required this.minBeauty,
    required this.minAffection,
    required this.needsOverworldRain,
    required this.partySpecies,
    required this.partyType,
    required this.relativePhysicalStats,
    required this.timeOfDay,
    required this.tradeSpecies,
    required this.turnUpsideDown,
  });

  factory EvolutionDetail.fromJson(Map<String, dynamic> json) =>
      EvolutionDetail(
        item: parseNamed(json['item']),
        trigger:
            NamedApiResource.fromJson(json['trigger'] as Map<String, dynamic>),
        gender: json['gender'] as int?,
        heldItem: parseNamed(json['held_item']),
        knownMove: parseNamed(json['known_move']),
        knownMoveType: parseNamed(json['known_move_type']),
        location: parseNamed(json['location']),
        minLevel: json['min_level'] as int?,
        minHappiness: json['min_happiness'] as int?,
        minBeauty: json['min_beauty'] as int?,
        minAffection: json['min_affection'] as int?,
        needsOverworldRain: json['needs_overworld_rain'] as bool? ?? false,
        partySpecies: parseNamed(json['party_species']),
        partyType: parseNamed(json['party_type']),
        relativePhysicalStats: json['relative_physical_stats'] as int?,
        timeOfDay: json['time_of_day'] as String? ?? '',
        tradeSpecies: parseNamed(json['trade_species']),
        turnUpsideDown: json['turn_upside_down'] as bool? ?? false,
      );
}