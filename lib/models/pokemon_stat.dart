import 'named_api_resource.dart';

class PokemonStat {
  final int baseStat;
  final int effort;
  final NamedApiResource stat;

  const PokemonStat({
    required this.baseStat,
    required this.effort,
    required this.stat,
  });

  factory PokemonStat.fromJson(Map<String, dynamic> json) => PokemonStat(
        baseStat: json['base_stat'] as int? ?? 0,
        effort: json['effort'] as int? ?? 0,
        stat: NamedApiResource.fromJson(json['stat'] as Map<String, dynamic>),
      );
}
