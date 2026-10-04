import 'named_api_resource.dart';
import 'pokemon_sprites.dart';
import 'pokemon_type.dart';

/// /pokemon-form/{id ou nome}
class PokemonForm {
  final int id;
  final String name;
  final int order;
  final int formOrder;
  final bool isDefault;
  final bool isBattleOnly;
  final bool isMega;
  final String formName;
  final NamedApiResource pokemon;
  final List<PokemonType> types;
  final NamedApiResource? versionGroup;
  final PokemonSprites sprites;

  const PokemonForm({
    required this.id,
    required this.name,
    required this.order,
    required this.formOrder,
    required this.isDefault,
    required this.isBattleOnly,
    required this.isMega,
    required this.formName,
    required this.pokemon,
    required this.types,
    required this.versionGroup,
    required this.sprites,
  });

  factory PokemonForm.fromJson(Map<String, dynamic> json) => PokemonForm(
        id: json['id'] as int,
        name: json['name'] as String,
        order: json['order'] as int? ?? 0,
        formOrder: json['form_order'] as int? ?? 0,
        isDefault: json['is_default'] as bool? ?? false,
        isBattleOnly: json['is_battle_only'] as bool? ?? false,
        isMega: json['is_mega'] as bool? ?? false,
        formName: json['form_name'] as String? ?? '',
        pokemon: NamedApiResource.fromJson(
            json['pokemon'] as Map<String, dynamic>),
        types: parseList(json['types'], PokemonType.fromJson),
        versionGroup: parseNamed(json['version_group']),
        sprites: PokemonSprites.fromJson(
            json['sprites'] as Map<String, dynamic>? ?? {}),
      );
}
