/// Estados de qualquer carregamento de um dado do tipo [T]
/// (mesmo padrão: Inicial, Carregando, Sucesso, Erro).
sealed class CarregamentoState<T> {
  const CarregamentoState();
}

class CarregamentoInicial<T> extends CarregamentoState<T> {
  const CarregamentoInicial();
}

class CarregamentoCarregando<T> extends CarregamentoState<T> {
  const CarregamentoCarregando();
}

class CarregamentoSucesso<T> extends CarregamentoState<T> {
  final T dados;

  const CarregamentoSucesso(this.dados);
}

class CarregamentoErro<T> extends CarregamentoState<T> {
  /// O erro original (ex.: PokeApiException), caso a tela queira usá-lo.
  final Object erro;

  const CarregamentoErro(this.erro);
}
