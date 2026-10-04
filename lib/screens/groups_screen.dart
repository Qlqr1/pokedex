import 'package:flutter/material.dart';
import 'move_list_screen.dart';
import 'pokemon_group_screen.dart';
import 'locations_group_screen.dart';
import 'item_list_screen.dart';

class _ApiGroup {
  final String title;
  final IconData icon;

  /// Tela que o grupo abre. Se for null, o grupo fica desabilitado ("em breve").
  final WidgetBuilder? builder;

  const _ApiGroup(this.title, this.icon, {this.builder});

  bool get enabled => builder != null;
}

// Não é const porque os builders são funções.
final _groups = <_ApiGroup>[
  const _ApiGroup('Berries', Icons.eco),
  const _ApiGroup('Contests', Icons.emoji_events),
  const _ApiGroup('Currencies', Icons.attach_money),
  const _ApiGroup('Encounters', Icons.explore),
  const _ApiGroup('Games', Icons.sports_esports),
  _ApiGroup(
    'Items',
    Icons.backpack,
    builder: (_) => const ItemListScreen(),
  ),
  _ApiGroup(
    'Locations',
    Icons.map,
    builder: (_) => const LocationsGroupScreen(),
  ),
  const _ApiGroup('Machines', Icons.album),
  _ApiGroup(
    'Moves',
    Icons.flash_on,
    builder: (_) => const MoveListScreen(),
  ),
  _ApiGroup(
    'Pokémon',
    Icons.catching_pokemon,
    builder: (_) => const PokemonGroupScreen(),
  ),
];

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokédex')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: _groups.length,
        itemBuilder: (context, i) {
          final g = _groups[i];
          return Opacity(
            opacity: g.enabled ? 1 : 0.45,
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (!g.enabled) {
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(content: Text('${g.title}: em breve')),
                      );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: g.builder!),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(g.icon, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      g.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}