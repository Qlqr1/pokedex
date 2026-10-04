import 'package:flutter/material.dart';

import '../utils/string_utils.dart';

/// Selo colorido com o nome de um tipo. [suffix] é opcional (ex.: "×2").
class TypeBadge extends StatelessWidget {
  final String type;
  final String? suffix;

  const TypeBadge({super.key, required this.type, this.suffix});

  static const Map<String, Color> colors = {
    'normal': Color(0xFFA8A77A),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'electric': Color(0xFFF7D02C),
    'grass': Color(0xFF7AC74C),
    'ice': Color(0xFF96D9D6),
    'fighting': Color(0xFFC22E28),
    'poison': Color(0xFFA33EA1),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: colors[type] ?? Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        suffix == null ? type.pretty : '${type.pretty} $suffix',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
