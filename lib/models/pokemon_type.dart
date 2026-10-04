import 'named_api_resource.dart';

/// Tipo de um Pokémon (slot 1 = principal, slot 2 = secundário).
class PokemonType {
  final int slot;
  final NamedApiResource type;

  const PokemonType({required this.slot, required this.type});

  factory PokemonType.fromJson(Map<String, dynamic> json) => PokemonType(
        slot: json['slot'] as int? ?? 0,
        type: NamedApiResource.fromJson(json['type'] as Map<String, dynamic>),
      );
}
