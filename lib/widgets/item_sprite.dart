import 'package:flutter/material.dart';

/// Sprite de item. As imagens da PokeAPI são pequenas (pixel art),
/// então desligamos a suavização para ampliar sem borrar.
class ItemSprite extends StatelessWidget {
  final String? url;
  final double size;
  const ItemSprite({super.key, required this.url, this.size = 40});

  /// Mesma URL que a API usa em `sprites.default`, montada pelo nome.
  static String urlFor(String name) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/$name.png';

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(Icons.backpack, size: size * 0.6, color: Colors.grey);
    return SizedBox(
      width: size,
      height: size,
      child: url == null
          ? fallback
          : Image.network(
              url!,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
              errorBuilder: (_, __, ___) => fallback,
            ),
    );
  }
}