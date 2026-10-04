import 'package:flutter/material.dart';
import 'ability_list_screen.dart';
import 'pokemon_list_screen.dart';

class _Endpoint {
  final String path;
  final String? subtitle; // null = ainda não implementado
  const _Endpoint(this.path, {this.subtitle});

  bool get enabled => subtitle != null;
}

const _endpoints = [
  _Endpoint('pokemon', subtitle: 'Lista de pokémons'), // principal
  _Endpoint('pokemon-species'),
  _Endpoint('pokemon-form'),
  _Endpoint('ability', subtitle: 'Lista de habilidades'),
  _Endpoint('type'),
  _Endpoint('stat'),
  _Endpoint('nature'),
  _Endpoint('egg-group'),
  _Endpoint('gender'),
  _Endpoint('growth-rate'),
  _Endpoint('characteristic'),
  _Endpoint('pokemon-color'),
  _Endpoint('pokemon-habitat'),
  _Endpoint('pokemon-shape'),
  _Endpoint('pokeathlon-stat'),
];

Widget _screenFor(String path) => switch (path) {
      'pokemon' => const PokemonListScreen(),
      'ability' => const AbilityListScreen(),
      _ => throw UnimplementedError(path),
    };

class PokemonGroupScreen extends StatelessWidget {
  const PokemonGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon')),
      body: ListView.separated(
        itemCount: _endpoints.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final e = _endpoints[i];
          return ListTile(
            enabled: e.enabled,
            title: Text('/${e.path}'),
            subtitle: Text(e.subtitle ?? 'Em breve'),
            trailing: e.enabled ? const Icon(Icons.chevron_right) : null,
            onTap: e.enabled
                ? () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => _screenFor(e.path)),
                    )
                : null,
          );
        },
      ),
    );
  }
}