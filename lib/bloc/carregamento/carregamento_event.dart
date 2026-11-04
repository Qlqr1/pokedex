/// Eventos que a página envia ao [CarregamentoBloc].
sealed class CarregamentoEvent {
  const CarregamentoEvent();
}

/// Primeira carga, disparada quando a página é criada.
class CarregamentoIniciado extends CarregamentoEvent {
  const CarregamentoIniciado();
}

/// Botão "Tentar novamente" depois de um erro.
class CarregamentoNovaTentativa extends CarregamentoEvent {
  const CarregamentoNovaTentativa();
}
