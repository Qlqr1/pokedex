import 'package:flutter/material.dart';

import 'poke_tile.dart';
import 'ability_list_screen.dart';
import 'characteristic_list_screen.dart';
import 'egg_group_list_screen.dart';
import 'habitat_list_screen.dart';
import 'nature_list_screen.dart';
import 'pokeathlon_stat_list_screen.dart';
import 'pokemon_list_screen.dart';
import 'stat_list_screen.dart';
import 'type_list_screen.dart';

class _Entry {
  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;
  const _Entry(this.icon, this.title, this.subtitle, this.builder);
}

final _entries = <_Entry>[
  _Entry(
    Icons.catching_pokemon,
    'Pokémon',
    'Todas as espécies',
    (_) => const PokemonListScreen(),
  ),
  _Entry(
    Icons.auto_awesome,
    'Habilidades',
    'Efeitos passivos',
    (_) => const AbilityListScreen(),
  ),
  _Entry(
    Icons.category,
    'Tipos',
    'Relações de dano, Pokémon e golpes',
    (_) => const TypeListScreen(),
  ),
  _Entry(
    Icons.bar_chart,
    'Status',
    'HP, Ataque, Defesa, Velocidade...',
    (_) => const StatListScreen(),
  ),
  _Entry(
    Icons.psychology,
    'Naturezas',
    'Personalidade e atributos',
    (_) => const NatureListScreen(),
  ),
  _Entry(
    Icons.egg,
    'Grupos de ovo',
    'Quem pode cruzar',
    (_) => const EggGroupListScreen(),
  ),
  _Entry(
    Icons.fingerprint,
    'Características',
    'A frase que indica o maior IV',
    (_) => const CharacteristicListScreen(),
  ),
  _Entry(
    Icons.terrain,
    'Habitats',
    'Onde cada espécie vive',
    (_) => const HabitatListScreen(),
  ),
  _Entry(
    Icons.directions_run,
    'Status do Pokéathlon',
    'Velocidade, Potência, Técnica...',
    (_) => const PokeathlonStatListScreen(),
  ),
];

class PokemonGroupScreen extends StatelessWidget {
  const PokemonGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon')),
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        itemCount: _entries.length,
        itemBuilder: (context, i) {
          final e = _entries[i];
          return PokeTile(
            leading: Icon(e.icon),
            title: e.title,
            subtitle: e.subtitle,
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: e.builder)),
          );
        },
      ),
    );
  }
}
