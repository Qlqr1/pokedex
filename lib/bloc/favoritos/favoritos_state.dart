import '../../models/favorito.dart';

/// Estados dos favoritos (mesmo padrão: Inicial, Carregando, Sucesso, Erro).
sealed class FavoritosState {
  const FavoritosState();
}

class FavoritosInicial extends FavoritosState {
  const FavoritosInicial();
}

class FavoritosCarregando extends FavoritosState {
  const FavoritosCarregando();
}

class FavoritosSucesso extends FavoritosState {
  final List<Favorito> favoritos;

  const FavoritosSucesso(this.favoritos);

  bool contem(int pokemonId) => favoritos.any((f) => f.pokemonId == pokemonId);
}

class FavoritosErro extends FavoritosState {
  final String mensagem;

  /// A API recusou o token (401): é preciso entrar de novo.
  final bool sessaoExpirada;

  const FavoritosErro(this.mensagem, {this.sessaoExpirada = false});
}