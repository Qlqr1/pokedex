import 'package:flutter/material.dart';

import '../repositories/ability_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/pokemon_repository.dart';
import '../theme/app_theme.dart';
import '../utils/search_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_search_field.dart';
import '../widgets/open_pokemon.dart';
import 'poke_tile.dart';
import 'ability_screen.dart';
import 'item_screen.dart';
import 'move_screen.dart';

class _Hit {
  final String name;
  final int? id;
  const _Hit(this.name, this.id);
}

/// Busca global: Pokémon, golpes, itens e habilidades. Cada lista de nomes é
/// baixada uma única vez, na primeira busca, e fica em cache.
class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  static const int _perSection = 6;

  String _query = '';
  Future<List<_Hit>>? _pokemon;
  Future<List<_Hit>>? _moves;
  Future<List<_Hit>>? _items;
  Future<List<_Hit>>? _abilities;

  Future<List<_Hit>> _resource(String endpoint, {int maxId = 100000}) async {
    final page = await PokemonRepository.shared.getResourceList(
      endpoint,
      limit: 2000,
      offset: 0,
    );
    return page.results
        .where((r) => (r.id ?? 0) < maxId)
        .map((r) => _Hit(r.name, r.id))
        .toList();
  }

  void _onSearch(String text) {
    final q = normalizeQuery(text);
    setState(() {
      _query = q;
      if (q.isNotEmpty) {
        // Ids acima de 10000 são formas alternativas de Pokémon.
        _pokemon ??= _resource('pokemon', maxId: 10000);
        _moves ??= _resource('move');
        _items ??= ItemRepository.instance.getList().then(
          (l) => l.map((r) => _Hit(r.name, r.id)).toList(),
        );
        _abilities ??= AbilityRepository.instance.getList().then(
          (l) => l.map((r) => _Hit(r.name, r.id)).toList(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: Column(
        children: [
          ListSearchField(
            hint: 'Pokémon, golpes, itens, habilidades',
            autofocus: true,
            onChanged: _onSearch,
          ),
          Expanded(
            child: _query.isEmpty
                ? const Center(
                    child: Text(
                      'Digite para buscar',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    children: [
                      _Section(
                        title: 'Pokémon',
                        icon: Icons.catching_pokemon,
                        future: _pokemon!,
                        query: _query,
                        limit: _perSection,
                        onTap: (h) => openPokemon(context, h.id ?? h.name),
                      ),
                      _Section(
                        title: 'Golpes',
                        icon: Icons.flash_on,
                        future: _moves!,
                        query: _query,
                        limit: _perSection,
                        onTap: (h) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MoveScreen(moveName: h.name),
                          ),
                        ),
                      ),
                      _Section(
                        title: 'Itens',
                        icon: Icons.backpack,
                        future: _items!,
                        query: _query,
                        limit: _perSection,
                        onTap: (h) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ItemScreen(itemName: h.name),
                          ),
                        ),
                      ),
                      _Section(
                        title: 'Habilidades',
                        icon: Icons.auto_awesome,
                        future: _abilities!,
                        query: _query,
                        limit: _perSection,
                        onTap: (h) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AbilityScreen(idOrName: h.name),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<List<_Hit>> future;
  final String query;
  final int limit;
  final void Function(_Hit) onTap;

  const _Section({
    required this.title,
    required this.icon,
    required this.future,
    required this.query,
    required this.limit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_Hit>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (snap.hasError) return const SizedBox.shrink();
        final all = snap.data!
            .where((h) => matchesQuery(h.name, h.id, query))
            .toList();
        if (all.isEmpty) return const SizedBox.shrink();
        final shown = all.take(limit).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
              child: Text(
                '$title (${all.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ),
            for (final h in shown)
              PokeTile(
                leading: Icon(icon, size: 20),
                title: h.name.pretty,
                subtitle: h.id == null ? null : '#${h.id}',
                onTap: () => onTap(h),
              ),
            if (all.length > shown.length)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 16, 4),
                child: Text(
                  '+${all.length - shown.length} resultados — refine a busca',
                  style: const TextStyle(color: AppColors.muted, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}
