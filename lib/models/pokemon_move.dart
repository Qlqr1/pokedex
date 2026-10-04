import 'named_api_resource.dart';

/// Movimento que o Pokémon aprende (e como/quando, por versão do jogo).
class PokemonMove {
  final NamedApiResource move;
  final List<PokemonMoveVersion> versionGroupDetails;

  const PokemonMove({required this.move, required this.versionGroupDetails});

  factory PokemonMove.fromJson(Map<String, dynamic> json) => PokemonMove(
        move: NamedApiResource.fromJson(json['move'] as Map<String, dynamic>),
        versionGroupDetails: parseList(
            json['version_group_details'], PokemonMoveVersion.fromJson),
      );
}

class PokemonMoveVersion {
  final int levelLearnedAt;
  final NamedApiResource moveLearnMethod;
  final NamedApiResource versionGroup;

  const PokemonMoveVersion({
    required this.levelLearnedAt,
    required this.moveLearnMethod,
    required this.versionGroup,
  });

  factory PokemonMoveVersion.fromJson(Map<String, dynamic> json) =>
      PokemonMoveVersion(
        levelLearnedAt: json['level_learned_at'] as int? ?? 0,
        moveLearnMethod: NamedApiResource.fromJson(
            json['move_learn_method'] as Map<String, dynamic>),
        versionGroup: NamedApiResource.fromJson(
            json['version_group'] as Map<String, dynamic>),
      );
}
