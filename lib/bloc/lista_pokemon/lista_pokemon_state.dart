import '../../models/models.dart';

/// Estados da lista de Pokémon (mesmo padrão: Inicial, Carregando, Sucesso, Erro).
sealed class ListaPokemonState {
  const ListaPokemonState();
}

class ListaPokemonInicial extends ListaPokemonState {
  const ListaPokemonInicial();
}

/// Primeira carga em andamento (a lista ainda está vazia).
class ListaPokemonCarregando extends ListaPokemonState {
  const ListaPokemonCarregando();
}

class ListaPokemonSucesso extends ListaPokemonState {
  final List<Pokemon> pokemons;

  /// Ainda existem páginas para carregar?
  final bool temMais;

  /// Está buscando a próxima página?
  final bool carregandoMais;

  /// Erro ao buscar a próxima página (a lista já carregada continua visível).
  final String? erroAoCarregarMais;

  const ListaPokemonSucesso({
    required this.pokemons,
    required this.temMais,
    this.carregandoMais = false,
    this.erroAoCarregarMais,
  });
}

/// Erro na primeira carga (não há nada para mostrar).
class ListaPokemonErro extends ListaPokemonState {
  final String mensagem;

  const ListaPokemonErro(this.mensagem);
}
