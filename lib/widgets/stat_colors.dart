import 'package:flutter/material.dart';

/// Cores dos status, seguindo a escala do Pokémon Database.
Color statColor(int value) {
  if (value < 26) return const Color(0xFFE53935); // vermelho
  if (value < 60) return const Color(0xFFFB8C00); // laranja
  if (value < 90) return const Color(0xFFFDD835); // amarelo
  if (value < 120) return const Color(0xFF9CCC65); // verde claro
  if (value < 150) return const Color(0xFF2E7D32); // verde escuro
  return const Color(0xFF1E88E5); // azul (150 ou mais)
}