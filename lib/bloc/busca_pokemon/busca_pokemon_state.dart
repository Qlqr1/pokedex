import '../../models/models.dart';

/// Estados da busca (mesmo padrão: Inicial, Carregando, Sucesso, Erro).
sealed class BuscaPokemonState {
  const BuscaPokemonState();
}

/// Nenhuma busca ativa (campo vazio): a tela mostra a lista normal.
class BuscaPokemonInicial extends BuscaPokemonState {
  const BuscaPokemonInicial();
}

/// Baixando a lista completa de nomes (só acontece na primeira busca).
class BuscaPokemonCarregando extends BuscaPokemonState {
  const BuscaPokemonCarregando();
}

class BuscaPokemonSucesso extends BuscaPokemonState {
  final List<NamedApiResource> resultados;

  const BuscaPokemonSucesso(this.resultados);
}

class BuscaPokemonErro extends BuscaPokemonState {
  final String mensagem;

  const BuscaPokemonErro(this.mensagem);
}
