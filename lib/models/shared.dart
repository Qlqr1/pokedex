import 'named_api_resource.dart';

/// Nome traduzido (names[] em vários endpoints).
class LocalizedName {
  final String name;
  final NamedApiResource language;

  const LocalizedName({required this.name, required this.language});

  factory LocalizedName.fromJson(Map<String, dynamic> json) => LocalizedName(
        name: json['name'] as String? ?? '',
        language: NamedApiResource.fromJson(
            json['language'] as Map<String, dynamic>),
      );
}

/// Descrição de efeito (abilities, moves, items).
class VerboseEffect {
  final String effect;
  final String shortEffect;
  final NamedApiResource language;

  const VerboseEffect({
    required this.effect,
    required this.shortEffect,
    required this.language,
  });

  factory VerboseEffect.fromJson(Map<String, dynamic> json) => VerboseEffect(
        effect: json['effect'] as String? ?? '',
        shortEffect: json['short_effect'] as String? ?? '',
        language: NamedApiResource.fromJson(
            json['language'] as Map<String, dynamic>),
      );
}

/// Texto de descrição da Pokédex (pokemon-species).
class FlavorText {
  final String text;
  final NamedApiResource language;
  final NamedApiResource? version;

  const FlavorText({
    required this.text,
    required this.language,
    this.version,
  });

  factory FlavorText.fromJson(Map<String, dynamic> json) => FlavorText(
        // A API devolve quebras de linha/página no texto; limpamos aqui.
        text: (json['flavor_text'] as String? ?? '')
            .replaceAll(RegExp(r'[\n\f]'), ' '),
        language: NamedApiResource.fromJson(
            json['language'] as Map<String, dynamic>),
        version: parseNamed(json['version']),
      );
}

/// Atalho para pegar o texto em um idioma (ex.: 'en', 'pt-BR').
extension LocalizedLookup on List<LocalizedName> {
  String? inLanguage(String code) {
    for (final n in this) {
      if (n.language.name == code) return n.name;
    }
    return null;
  }
}
