import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/busca_pokemon/busca_pokemon_bloc.dart';
import '../bloc/busca_pokemon/busca_pokemon_event.dart';
import '../bloc/busca_pokemon/busca_pokemon_state.dart';
import '../bloc/lista_pokemon/lista_pokemon_bloc.dart';
import '../bloc/lista_pokemon/lista_pokemon_event.dart';
import '../bloc/lista_pokemon/lista_pokemon_state.dart';
import '../models/models.dart';
import '../repositories/pokemon_repository.dart';
import '../theme/app_theme.dart';
import '../utils/string_utils.dart';
import '../utils/type_colors.dart';
import '../widgets/list_search_field.dart';
import '../widgets/type_badge.dart';
import 'pokemon_screen.dart';

/// Lista básica de Pokémon, na ordem padrão da Pokédex, com scroll infinito e
/// busca por nome ou número. Cada item mostra sprite, número, nome, peso,
/// altura e tipagem.
///
/// O carregamento paginado é controlado pelo [ListaPokemonBloc] e a busca pelo
/// [BuscaPokemonBloc]; a tela só envia eventos e desenha os estados.
class PokemonListScreen extends StatelessWidget {
  const PokemonListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ListaPokemonBloc()..add(const ListaPokemonIniciada()),
        ),
        BlocProvider(create: (_) => BuscaPokemonBloc()),
      ],
      child: const _PokemonListView(),
    );
  }
}

class _PokemonListView extends StatefulWidget {
  const _PokemonListView();

  @override
  State<_PokemonListView> createState() => _PokemonListViewState();
}

class _PokemonListViewState extends State<_PokemonListView> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Durante a busca a lista paginada não está na tela.
    final buscando =
        context.read<BuscaPokemonBloc>().state is! BuscaPokemonInicial;
    if (buscando) return;

    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
      context.read<ListaPokemonBloc>().add(const ListaPokemonMaisSolicitado());
    }
  }

  void _onSearch(String texto) {
    context.read<BuscaPokemonBloc>().add(BuscaPokemonTextoAlterado(texto));
  }

  Future<void> _refresh() async {
    final lista = context.read<ListaPokemonBloc>();
    context.read<BuscaPokemonBloc>().add(const BuscaPokemonAtualizada());
    lista.add(const ListaPokemonAtualizada());
    // Mantém o indicador do RefreshIndicator até o bloc emitir o resultado.
    await lista.stream.firstWhere((s) => s is! ListaPokemonCarregando);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon')),
      body: Column(
        children: [
          ListSearchField(
            hint: 'Buscar por nome ou número',
            onChanged: _onSearch,
          ),
          Expanded(
            child: BlocBuilder<BuscaPokemonBloc, BuscaPokemonState>(
              builder: (context, busca) => busca is BuscaPokemonInicial
                  ? _buildBody()
                  : _buildSearchResults(busca),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuscaPokemonState busca) {
    return switch (busca) {
      BuscaPokemonInicial() || BuscaPokemonCarregando() => const Center(
        child: CircularProgressIndicator(),
      ),
      BuscaPokemonErro(:final mensagem) => _ErrorView(
        message: mensagem,
        onRetry: () => context.read<BuscaPokemonBloc>().add(
          const BuscaPokemonNovaTentativa(),
        ),
      ),
      BuscaPokemonSucesso(:final resultados) =>
        resultados.isEmpty
            ? const Center(child: Text('Nenhum Pokémon encontrado.'))
            : ListView.builder(
                itemCount: resultados.length,
                itemBuilder: (context, index) => _LazyPokemonTile(
                  key: ValueKey(resultados[index].name),
                  name: resultados[index].name,
                ),
              ),
    };
  }

  Widget _buildBody() {
    return BlocBuilder<ListaPokemonBloc, ListaPokemonState>(
      builder: (context, state) {
        return switch (state) {
          ListaPokemonInicial() || ListaPokemonCarregando() => const Center(
            child: CircularProgressIndicator(),
          ),
          ListaPokemonErro(:final mensagem) => _ErrorView(
            message: mensagem,
            onRetry: () => context.read<ListaPokemonBloc>().add(
              const ListaPokemonIniciada(),
            ),
          ),
          ListaPokemonSucesso() => _buildLista(state),
        };
      },
    );
  }

  Widget _buildLista(ListaPokemonSucesso state) {
    final temItemExtra = state.temMais || state.erroAoCarregarMais != null;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scroll,
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: state.pokemons.length + (temItemExtra ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.pokemons.length) {
            return _PokemonTile(pokemon: state.pokemons[index]);
          }
          // Último item: erro com "tentar de novo" ou indicador de carregamento.
          if (state.erroAoCarregarMais != null) {
            return _ErrorView(
              message: state.erroAoCarregarMais!,
              onRetry: () => context.read<ListaPokemonBloc>().add(
                const ListaPokemonMaisSolicitado(),
              ),
              compact: true,
            );
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
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.track,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.name.pretty,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              snapshot.hasError
                  ? IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () => setState(_load),
                    )
                  : const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
            ],
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
    final primary = pokemon.typeNames.isNotEmpty
        ? pokemon.typeNames.first
        : 'normal';
    final colors = typeGradient(primary);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PokemonScreen(pokemon: pokemon)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                // Miniatura sobre gradiente da cor do tipo
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.catching_pokemon,
                        size: 40,
                        color: Color.fromRGBO(255, 255, 255, .25),
                      ),
                      if (sprite != null)
                        Image.network(
                          sprite,
                          width: 52,
                          height: 52,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${pokemon.id.toString().padLeft(4, '0')}',
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        pokemon.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: pokemon.typeNames
                            .map((t) => TypeBadge(type: t))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${pokemon.heightInMeters} m\n${pokemon.weightInKg} kg',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
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
          onPressed: onRetry,
          child: const Text('Tentar novamente'),
        ),
      ],
    );

    return compact
        ? Padding(padding: const EdgeInsets.all(16), child: content)
        : Center(
            child: Padding(padding: const EdgeInsets.all(24), child: content),
          );
  }
}
