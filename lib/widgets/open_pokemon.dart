import 'package:flutter/material.dart';

import '../repositories/pokemon_repository.dart';
import '../screens/pokemon_screen.dart';
import '../services/pokeapi_service.dart'; // PokeApiException

/// Carrega o Pokémon (por id ou nome) e abre a PokemonScreen.
Future<void> openPokemon(BuildContext context, Object idOrName) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );
  try {
    final pokemon = await PokemonRepository.shared.getPokemon(idOrName);
    navigator.pop(); // fecha o loading
    await navigator.push(
      MaterialPageRoute(builder: (_) => PokemonScreen(pokemon: pokemon)),
    );
  } on PokeApiException {
    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir este Pokémon.')),
    );
  }
}