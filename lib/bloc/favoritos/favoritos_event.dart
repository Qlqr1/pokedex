sealed class FavoritosEvent {
  const FavoritosEvent();
}

/// Carrega a lista do usuário logado (após o login e em "Tentar novamente").
class FavoritosIniciados extends FavoritosEvent {
  const FavoritosIniciados();
}

/// Ao sair da conta: esquece os favoritos que estavam na memória.
class FavoritosLimpos extends FavoritosEvent {
  const FavoritosLimpos();
}

/// Toque no coração: favorita se ainda não é favorito, remove se já é.
class FavoritoAlternado extends FavoritosEvent {
  final int pokemonId;
  final String nome;

  const FavoritoAlternado({required this.pokemonId, required this.nome});
}