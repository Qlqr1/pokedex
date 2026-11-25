import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/favoritos/favoritos_bloc.dart';
import '../bloc/favoritos/favoritos_event.dart';
import '../bloc/favoritos/favoritos_state.dart';
import '../screens/login_screen.dart';

/// Botão de coração: cheio = favorito, vazio = não favorito.
/// Sem login, abre a tela de entrar.
class FavoritoButton extends StatelessWidget {
  final int pokemonId;
  final String nome;

  const FavoritoButton({super.key, required this.pokemonId, required this.nome});

  @override
  Widget build(BuildContext context) {
    final logado = context.watch<AuthBloc>().state is AuthAutenticado;

    return BlocBuilder<FavoritosBloc, FavoritosState>(
      builder: (context, state) {
        final carregado = state is FavoritosSucesso;
        final favorito = logado && state is FavoritosSucesso && state.contem(pokemonId);

        VoidCallback? aoTocar;
        if (!logado) {
          aoTocar = () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
        } else if (carregado) {
          aoTocar = () => context.read<FavoritosBloc>().add(
            FavoritoAlternado(pokemonId: pokemonId, nome: nome),
          );
        }

        return IconButton(
          tooltip: !logado
              ? 'Entre para favoritar'
              : favorito
              ? 'Remover dos favoritos'
              : 'Favoritar',
          icon: Icon(favorito ? Icons.favorite : Icons.favorite_border),
          onPressed: aoTocar,
        );
      },
    );
  }
}