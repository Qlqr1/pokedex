import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/pokemon_repository.dart';
import '../services/pokeapi_service.dart'; // PokeApiException
import '../utils/search_utils.dart';
import '../widgets/list_search_field.dart';
import '../widgets/move_tile.dart';
import 'move_screen.dart';

/// Grupo Moves: lista paginada de todos os golpes, com scroll infinito e busca.
/// A listagem da API traz só nome e URL; cada item busca os detalhes sozinho
/// quando aparece na tela.
class MoveListScreen extends StatefulWidget {
  const MoveListScreen({super.key});

  @override
  State<MoveListScreen> createState() => _MoveListScreenState();
}

class _MoveListScreenState extends State<MoveListScreen> {
  static const int _pageSize = 40;

  final PokemonRepository _repository = PokemonRepository.shared;
  final ScrollController _scroll = ScrollController();
  final List<NamedApiResource> _moves = [];

  int _offset = 0;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  // Busca: baixa a lista completa de nomes (só uma vez, na primeira busca) e
  // filtra localmente. Os detalhes de cada resultado são carregados sob demanda.
  String _query = '';
  Future<List<NamedApiResource>>? _allMoves;

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

  Future<List<NamedApiResource>> _loadAllMoves() async {
    final page = await _repository.getResourceList(
      'move',
      limit: 2000,
      offset: 0,
    );
    return page.results;
  }

  void _onSearch(String text) {
    final q = normalizeQuery(text);
    setState(() {
      _query = q;
      if (q.isNotEmpty) _allMoves ??= _loadAllMoves();
    });
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final page = await _repository.getResourceList(
        'move',
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _moves.addAll(page.results);
        _offset += _pageSize;
        _hasMore = page.next != null;
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
    _repository.clearCache();
    setState(() {
      _moves.clear();
      _offset = 0;
      _hasMore = true;
      _error = null;
      _allMoves = null;
    });
    await _loadMore();
  }

  void _openMove(String name) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MoveScreen(moveName: name)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Golpes')),
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
      future: _allMoves,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(
            message: 'Não foi possível carregar a lista para busca.',
            onRetry: () => setState(() => _allMoves = _loadAllMoves()),
          );
        }
        final results =
            snapshot.data!
            .where((m) => matchesQuery(m.name, m.id, _query))
            .toList();
        if (results.isEmpty) {
          return const Center(child: Text('Nenhum golpe encontrado.'));
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final move = results[index];
            return MoveTile(
              key: ValueKey(move.name),
              moveName: move.name,
              leading: '#${move.id ?? ''}',
              onTap: () => _openMove(move.name),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    if (_moves.isEmpty) {
      if (_error != null) {
        return _ErrorView(message: _error!, onRetry: _loadMore);
      }
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _moves.length + ((_hasMore || _error != null) ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _moves.length) {
            final move = _moves[index];
            return MoveTile(
              moveName: move.name,
              leading: '#${move.id ?? ''}',
              onTap: () => _openMove(move.name),
            );
          }
          if (_error != null) {
            return _ErrorView(
                message: _error!, onRetry: _loadMore, compact: true);
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
        ElevatedButton(
            onPressed: onRetry, child: const Text('Tentar novamente')),
      ],
    );

    return compact
        ? Padding(padding: const EdgeInsets.all(16), child: content)
        : Center(
            child: Padding(padding: const EdgeInsets.all(24), child: content));
  }
}