import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/carregamento/carregamento_bloc.dart';
import '../bloc/carregamento/carregamento_event.dart';
import '../bloc/carregamento/carregamento_state.dart';
import '../bloc/favoritos/favoritos_bloc.dart';
import '../bloc/favoritos/favoritos_event.dart';
import '../bloc/favoritos/favoritos_state.dart';
import '../models/favorito.dart';
import '../models/models.dart';
import '../repositories/pokemon_repository.dart';
import '../theme/app_theme.dart';
import '../utils/string_utils.dart'; // .pretty
import '../utils/type_colors.dart';
import '../widgets/open_pokemon.dart';
import '../widgets/type_badge.dart';
import 'login_screen.dart';

/// Favoritos da conta logada. Sem login, convida a entrar.
class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: [
          if (auth is AuthAutenticado) ...[
            Center(
              child: Text(auth.usuario, style: const TextStyle(fontSize: 13)),
            ),
            IconButton(
              tooltip: 'Sair da conta',
              icon: const Icon(Icons.logout),
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthSairSolicitado()),
            ),
          ],
        ],
      ),
      body: switch (auth) {
        AuthInicial() => const Center(child: CircularProgressIndicator()),
        AuthAutenticado() => const _ListaFavoritos(),
        _ => const _PedirLogin(),
      },
    );
  }
}

class _PedirLogin extends StatelessWidget {
  const _PedirLogin();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_border, size: 48, color: AppColors.muted),
            const SizedBox(height: 12),
            const Text(
              'Entre na sua conta para ver e salvar seus favoritos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              ),
              child: const Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaFavoritos extends StatelessWidget {
  const _ListaFavoritos();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritosBloc, FavoritosState>(
      builder: (context, state) {
        return switch (state) {
          FavoritosInicial() || FavoritosCarregando() => const Center(
            child: CircularProgressIndicator(),
          ),
          FavoritosErro(:final mensagem, :final sessaoExpirada) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mensagem, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => sessaoExpirada
                        ? context.read<AuthBloc>().add(const AuthSairSolicitado())
                        : context.read<FavoritosBloc>().add(
                            const FavoritosIniciados(),
                          ),
                    child: Text(
                      sessaoExpirada ? 'Entrar novamente' : 'Tentar novamente',
                    ),
                  ),
                ],
              ),
            ),
          ),
          FavoritosSucesso(:final favoritos) =>
            favoritos.isEmpty
                ? const _SemFavoritos()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: favoritos.length,
                    itemBuilder: (context, index) => _FavoritoTile(
                      // A chave evita que a miniatura de um item removido
                      // fique no item que ocupa o seu lugar.
                      key: ValueKey(favoritos[index].pokemonId),
                      favorito: favoritos[index],
                    ),
                  ),
        };
      },
    );
  }
}

class _SemFavoritos extends StatelessWidget {
  const _SemFavoritos();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 48, color: AppColors.muted),
            SizedBox(height: 12),
            Text(
              'Você ainda não favoritou nenhum Pokémon.\n'
              'Toque no coração na página de um Pokémon para salvá-lo aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item da lista: mostra número e nome na hora e carrega o Pokémon da forma
/// favoritada (miniatura e tipos) pelo repository, que tem cache.
class _FavoritoTile extends StatelessWidget {
  final Favorito favorito;

  const _FavoritoTile({super.key, required this.favorito});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CarregamentoBloc<Pokemon>(
        loader: () => PokemonRepository.shared.getPokemon(favorito.nome),
      )..add(const CarregamentoIniciado()),
      child: BlocBuilder<CarregamentoBloc<Pokemon>, CarregamentoState<Pokemon>>(
        builder: (context, state) {
          final pokemon = state is CarregamentoSucesso<Pokemon>
              ? state.dados
              : null;
          // Para formas (Mega, regionais...), mostra o número da espécie.
          final numero = pokemon?.species.id ?? favorito.pokemonId;

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
                onTap: () => openPokemon(context, favorito.nome),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
                  child: Row(
                    children: [
                      _Miniatura(pokemon: pokemon),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '#${numero.toString().padLeft(4, '0')}',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              favorito.nome.pretty,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (pokemon != null &&
                                pokemon.typeNames.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Wrap(
                                spacing: 5,
                                runSpacing: 4,
                                children: pokemon.typeNames
                                    .map((t) => TypeBadge(type: t))
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remover dos favoritos',
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        ),
                        onPressed: () => context.read<FavoritosBloc>().add(
                          FavoritoAlternado(
                            pokemonId: favorito.pokemonId,
                            nome: favorito.nome,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Miniatura sobre o gradiente do tipo (igual à da lista de Pokémon).
class _Miniatura extends StatelessWidget {
  final Pokemon? pokemon;

  const _Miniatura({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final p = pokemon;

    if (p == null) {
      return Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          color: AppColors.track,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.catching_pokemon,
          size: 28,
          color: AppColors.muted,
        ),
      );
    }

    final sprite = p.sprites.frontDefault;
    final primary = p.typeNames.isNotEmpty ? p.typeNames.first : 'normal';

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: typeGradient(primary),
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
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}