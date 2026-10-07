import 'package:flutter/material.dart';

const _colors = {
  'normal': Color(0xFFA8A77A),
  'fire': Color(0xFFEE8130),
  'water': Color(0xFF6390F0),
  'electric': Color(0xFFF7D02C),
  'grass': Color(0xFF4CAF6A),
  'ice': Color(0xFF96D9D6),
  'fighting': Color(0xFFC22E28),
  'poison': Color(0xFF9B59B6),
  'ground': Color(0xFFE2BF65),
  'flying': Color(0xFFA98FF3),
  'psychic': Color(0xFFF95587),
  'bug': Color(0xFFA6B91A),
  'rock': Color(0xFFB6A136),
  'ghost': Color(0xFF735797),
  'dragon': Color(0xFF6F35FC),
  'dark': Color(0xFF705746),
  'steel': Color(0xFFB7B7CE),
  'fairy': Color(0xFFD685AD),
};

const _labels = {
  'normal': 'Normal',
  'fire': 'Fogo',
  'water': 'Água',
  'electric': 'Elétrico',
  'grass': 'Planta',
  'ice': 'Gelo',
  'fighting': 'Lutador',
  'poison': 'Veneno',
  'ground': 'Terra',
  'flying': 'Voador',
  'psychic': 'Psíquico',
  'bug': 'Inseto',
  'rock': 'Pedra',
  'ghost': 'Fantasma',
  'dragon': 'Dragão',
  'dark': 'Sombrio',
  'steel': 'Aço',
  'fairy': 'Fada',
  'stellar': 'Estelar',
};

Color typeColor(String type) => _colors[type] ?? const Color(0xFF68A090);

/// Cor do tipo e uma versão mais escura, para gradientes.
List<Color> typeGradient(String type) {
  final c = typeColor(type);
  final hsl = HSLColor.fromColor(c);
  final darker = hsl
      .withLightness((hsl.lightness - 0.16).clamp(0.0, 1.0))
      .toColor();
  return [c, darker];
}

String typeLabel(String type) => _labels[type] ?? type;
