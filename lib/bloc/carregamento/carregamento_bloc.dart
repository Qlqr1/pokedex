import 'package:flutter_bloc/flutter_bloc.dart';

import 'carregamento_event.dart';
import 'carregamento_state.dart';

/// BLoC genérico: executa uma função assíncrona que devolve um [T] e emite os
/// estados Inicial -> Carregando -> Sucesso/Erro.
///
/// Não conhece widgets nem a PokéAPI: quem sabe o que carregar é o [loader]
/// (normalmente uma chamada ao PokemonRepository, que já guarda o cache e não
/// guarda falhas, então "Tentar novamente" faz uma nova requisição).
class CarregamentoBloc<T>
    extends Bloc<CarregamentoEvent, CarregamentoState<T>> {
  final Future<T> Function() _loader;

  // Sem "const" no estado inicial: const não aceita o parâmetro de tipo T.
  CarregamentoBloc({required Future<T> Function() loader})
    : _loader = loader,
      super(CarregamentoInicial<T>()) {
    on<CarregamentoIniciado>(_carregar);
    on<CarregamentoNovaTentativa>(_carregar);
  }

  Future<void> _carregar(
    CarregamentoEvent event,
    Emitter<CarregamentoState<T>> emit,
  ) async {
    // Evita duas requisições se o botão for tocado várias vezes.
    if (state is CarregamentoCarregando<T>) return;

    emit(CarregamentoCarregando<T>());
    try {
      final dados = await _loader();
      emit(CarregamentoSucesso<T>(dados));
    } catch (e) {
      emit(CarregamentoErro<T>(e));
    }
  }
}
