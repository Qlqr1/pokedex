import '../utils/string_utils.dart';

/// Uma imagem da galeria, já com grupo e nome para exibir.
class SpriteImage {
  final String group;
  final String label;
  final String url;

  const SpriteImage({
    required this.group,
    required this.label,
    required this.url,
  });
}

/// Imagens do Pokémon. Também serve para as sprites de PokemonForm.
class PokemonSprites {
  static const String groupDefault = 'Padrão';
  static const String groupArtwork = 'Arte oficial';
  static const String groupHome = 'Pokémon HOME';
  static const String groupShowdown = 'Showdown (animado)';
  static const String groupOther = 'Outras';
  static const String groupByGame = 'Por jogo';

  static const List<String> groupOrder = [
    groupDefault,
    groupArtwork,
    groupHome,
    groupShowdown,
    groupOther,
    groupByGame,
  ];

  final String? frontDefault;
  final String? frontShiny;
  final String? backDefault;
  final String? backShiny;

  /// Arte oficial em alta resolução (other.official-artwork).
  final String? officialArtwork;

  /// Todas as imagens encontradas na resposta, agrupadas e na ordem de exibição.
  final List<SpriteImage> gallery;

  const PokemonSprites({
    this.frontDefault,
    this.frontShiny,
    this.backDefault,
    this.backShiny,
    this.officialArtwork,
    this.gallery = const [],
  });

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    final other = json['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;
    return PokemonSprites(
      frontDefault: json['front_default'] as String?,
      frontShiny: json['front_shiny'] as String?,
      backDefault: json['back_default'] as String?,
      backShiny: json['back_shiny'] as String?,
      officialArtwork: artwork?['front_default'] as String?,
      gallery: _buildGallery(json),
    );
  }

  // ---------------------------------------------------------------------------
  // Galeria: percorre todo o JSON de sprites e coleta cada URL de imagem.
  // ---------------------------------------------------------------------------

  static List<SpriteImage> _buildGallery(Map<String, dynamic> json) {
    final buckets = <String, List<SpriteImage>>{};
    final seen = <String>{};

    void walk(dynamic node, List<String> path) {
      if (node is String) {
        // SVG (Dream World) não é suportado pelo Image.network do Flutter.
        if (!node.startsWith('http') || node.endsWith('.svg')) return;
        if (!seen.add(node)) return;
        final image = _describe(path, node);
        buckets.putIfAbsent(image.group, () => []).add(image);
      } else if (node is Map<String, dynamic>) {
        node.forEach((key, value) => walk(value, [...path, key]));
      }
    }

    walk(json, const []);

    return [
      for (final group in groupOrder) ...?buckets[group],
    ];
  }

  static SpriteImage _describe(List<String> path, String url) {
    final key = path.last;

    if (path.length == 1) {
      return SpriteImage(group: groupDefault, label: _keyLabel(key), url: url);
    }

    if (path.first == 'other') {
      switch (path[1]) {
        case 'official-artwork':
          return SpriteImage(
              group: groupArtwork, label: _artLabel(key), url: url);
        case 'home':
          return SpriteImage(group: groupHome, label: _artLabel(key), url: url);
        case 'showdown':
          return SpriteImage(
              group: groupShowdown, label: _keyLabel(key), url: url);
      }
      return SpriteImage(group: groupOther, label: _keyLabel(key), url: url);
    }

    if (path.first == 'versions') {
      // versions / generation-i / red-blue / front_default
      final parts = <String>[];
      for (var i = 1; i < path.length; i++) {
        final part = path[i];
        if (part.startsWith('generation-')) {
          parts.add(
              'Geração ${part.substring('generation-'.length).toUpperCase()}');
        } else if (i == path.length - 1) {
          parts.add(_keyLabel(part));
        } else {
          parts.add(part.pretty);
        }
      }
      return SpriteImage(
          group: groupByGame, label: parts.join(' · '), url: url);
    }

    return SpriteImage(group: groupOther, label: _keyLabel(key), url: url);
  }

  /// Nome para sprites de jogo: frente/costas, normal/shiny, macho/fêmea.
  static String _keyLabel(String key) {
    const labels = {
      'front_default': 'Frente',
      'back_default': 'Costas',
      'front_shiny': 'Frente · shiny',
      'back_shiny': 'Costas · shiny',
      'front_female': 'Frente · fêmea',
      'back_female': 'Costas · fêmea',
      'front_shiny_female': 'Frente · shiny fêmea',
      'back_shiny_female': 'Costas · shiny fêmea',
    };
    return labels[key] ?? key.replaceAll('_', '-').pretty;
  }

  /// Nome para artes (só existe a frente): normal ou shiny, macho ou fêmea.
  static String _artLabel(String key) {
    const labels = {
      'front_default': 'Normal',
      'front_shiny': 'Shiny',
      'front_female': 'Fêmea',
      'front_shiny_female': 'Shiny fêmea',
    };
    return labels[key] ?? _keyLabel(key);
  }
}