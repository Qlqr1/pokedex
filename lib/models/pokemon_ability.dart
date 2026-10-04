import 'named_api_resource.dart';

/// Habilidade dentro do /pokemon (para o detalhe completo, veja Ability).
class PokemonAbility {
  final bool isHidden;
  final int slot;
  final NamedApiResource ability;

  const PokemonAbility({
    required this.isHidden,
    required this.slot,
    required this.ability,
  });

  factory PokemonAbility.fromJson(Map<String, dynamic> json) =>
      PokemonAbility(
        isHidden: json['is_hidden'] as bool? ?? false,
        slot: json['slot'] as int? ?? 0,
        ability: NamedApiResource.fromJson(
            json['ability'] as Map<String, dynamic>),
      );
}
