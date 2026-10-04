import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/pokemon_repository.dart';
import '../services/pokeapi_service.dart'; // PokeApiException
import '../utils/search_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/list_search_field.dart';
import '../widgets/type_badge.dart';
import 'pokemon_screen.dart';

/// Lista básica de Pokémon, na ordem padrão da Pokédex, com scroll infinito e
/// busca por nome ou número. Cada item mostra sprite, número, nome, peso,
/// altura e tipagem.
class PokemonListScreen extends StatefulWidget {
  const PokemonListScreen({super.key});

  @override
  State<PokemonListScreen> createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  static const int _pageSize = 20;

  /// Na PokéAPI, ids acima disso são formas alternativas (Mega, regionais...),
  /// que já aparecem no seletor de formas da página do Pokémon.
  static const int _maxSpeciesId = 10000;

  final PokemonRepository _repository = PokemonRepository.shared;
  final ScrollController _scroll = ScrollController();
  final List<Pokemon> _pokemons = [];

  int _offset = 0;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  // Busca: baixa a lista completa de nomes (só uma vez, na primeira busca) e
  // filtra localmente. Os detalhes de cada resultado são carregados sob demanda.
  String _query = '';
  Future<List<NamedApiResource>>? _allNames;

  bool get _searching => _query.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_searching) return;
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<List<NamedApiResource>> _loadAllNames() async {
    final page = await _repository.getResourceList(
      'pokemon',
      limit: 2000,
      offset: 0,
    );
    return page.results.where((r) => (r.id ?? 0) < _maxSpeciesId).toList();
  }

  void _onSearch(String text) {
    final q = normalizeQuery(text);
    setState(() {
      _query = q;
      if (q.isNotEmpty) _allNames ??= _loadAllNames();
    });
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await _repository.getPokemonPage(
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _pokemons.addAll(page);
        _offset += _pageSize;
        _hasMore = page.length == _pageSize;
        _loading = false;
      });
    } on PokeApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.isRateLimited
            ? 'Muitas requisições. Aguarde um instante e tente de novo.'
            : e.message;
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    _repository.clearCache(); // puxar para atualizar busca de novo na API
    setState(() {
      _pokemons.clear();
      _offset = 0;
      _hasMore = true;
      _error = null;
      _allNames = null;
    });
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon')),
      body: Column(
        children: [
          ListSearchField(
              hint: 'Buscar por nome ou número', onChanged: _onSearch),
          Expanded(child: _searching ? _buildSearchResults() : _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<NamedApiResource>>(
      future: _allNames,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(
            message: 'Não foi possível carregar a lista para busca.',
            onRetry: () => setState(() => _allNames = _loadAllNames()),
          );
        }
        final results = snapshot.data!
            .where((r) => matchesQuery(r.name, r.id, _query))
            .toList();
        if (results.isEmpty) {
          return const Center(child: Text('Nenhum Pokémon encontrado.'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) => _LazyPokemonTile(
            key: ValueKey(results[index].name),
            name: results[index].name,
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_pokemons.isEmpty) {
      if (_error != null) return _ErrorView(message: _error!, onRetry: _loadMore);
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _pokemons.length + ((_hasMore || _error != null) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _pokemons.length) {
            return _PokemonTile(pokemon: _pokemons[index]);
          }
          // Último item: erro com "tentar de novo" ou indicador de carregamento.
          if (_error != null) {
            return _ErrorView(message: _error!, onRetry: _loadMore, compact: true);
          }
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

/// Resultado de busca: mostra o nome na hora e carrega o Pokémon completo
/// (sprite, tipos...) só quando o item aparece na tela.
class _LazyPokemonTile extends StatefulWidget {
  final String name;

  const _LazyPokemonTile({super.key, required this.name});

  @override
  State<_LazyPokemonTile> createState() => _LazyPokemonTileState();
}

class _LazyPokemonTileState extends State<_LazyPokemonTile> {
  late Future<Pokemon> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = PokemonRepository.shared.getPokemon(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Pokemon>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasData) return _PokemonTile(pokemon: snapshot.data!);
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
          ),
          title: Text(
            widget.name.pretty,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          trailing: snapshot.hasError
              ? IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => setState(_load),
                )
              : const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
        );
      },
    );
  }
}

class _PokemonTile extends StatelessWidget {
  final Pokemon pokemon;

  const _PokemonTile({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final sprite = pokemon.sprites.frontDefault;

    return ListTile(
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: sprite != null ? NetworkImage(sprite) : null,
        child: sprite == null ? const Icon(Icons.catching_pokemon) : null,
      ),
      title: Text(
        '#${pokemon.id.toString().padLeft(4, '0')}  ${pokemon.displayName}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peso: ${pokemon.weightInKg} kg   Altura: ${pokemon.heightInMeters} m'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              children: pokemon.typeNames.map((t) => TypeBadge(type: t)).toList(),
            ),
          ],
        ),
      ),
      isThreeLine: true,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PokemonScreen(pokemon: pokemon)),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool compact;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        ElevatedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
      ],
    );

    return compact
        ? Padding(padding: const EdgeInsets.all(16), child: content)
        : Center(child: Padding(padding: const EdgeInsets.all(24), child: content));
  }
}