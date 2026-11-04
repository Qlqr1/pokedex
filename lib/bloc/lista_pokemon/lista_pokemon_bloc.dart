import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/pokemon_repository.dart';
import '../../services/pokeapi_service.dart'; // PokeApiException
import 'lista_pokemon_event.dart';
import 'lista_pokemon_state.dart';

/// Controla a lista paginada de Pokémon. Não conhece widgets: recebe eventos,
/// consulta o [PokemonRepository] e emite estados.
class ListaPokemonBloc extends Bloc<ListaPokemonEvent, ListaPokemonState> {
  static const int _tamanhoPagina = 20;

  final PokemonRepository _repository;

  ListaPokemonBloc({PokemonRepository? repository})
    : _repository = repository ?? PokemonRepository.shared,
      super(const ListaPokemonInicial()) {
    on<ListaPokemonIniciada>(_aoIniciar);
    on<ListaPokemonMaisSolicitado>(_aoSolicitarMais);
    on<ListaPokemonAtualizada>(_aoAtualizar);
  }

  Future<void> _aoIniciar(
    ListaPokemonIniciada event,
    Emitter<ListaPokemonState> emit,
  ) async {
    emit(const ListaPokemonCarregando());
    await _carregarPrimeiraPagina(emit);
  }

  Future<void> _aoAtualizar(
    ListaPokemonAtualizada event,
    Emitter<ListaPokemonState> emit,
  ) async {
    // Sem emitir "Carregando": a lista atual continua na tela enquanto o
    // RefreshIndicator mostra o seu próprio indicador.
    _repository.clearCache();
    await _carregarPrimeiraPagina(emit);
  }

  Future<void> _aoSolicitarMais(
    ListaPokemonMaisSolicitado event,
    Emitter<ListaPokemonState> emit,
  ) async {
    final atual = state;
    if (atual is! ListaPokemonSucesso ||
        atual.carregandoMais ||
        !atual.temMais) {
      return;
    }

    emit(
      ListaPokemonSucesso(
        pokemons: atual.pokemons,
        temMais: atual.temMais,
        carregandoMais: true,
      ),
    );

    try {
      final pagina = await _repository.getPokemonPage(
        limit: _tamanhoPagina,
        offset: atual.pokemons.length,
      );
      emit(
        ListaPokemonSucesso(
          pokemons: [...atual.pokemons, ...pagina],
          temMais: pagina.length == _tamanhoPagina,
        ),
      );
    } catch (e) {
      emit(
        ListaPokemonSucesso(
          pokemons: atual.pokemons,
          temMais: atual.temMais,
          erroAoCarregarMais: _mensagemDeErro(e),
        ),
      );
    }
  }

  Future<void> _carregarPrimeiraPagina(Emitter<ListaPokemonState> emit) async {
    try {
      final pagina = await _repository.getPokemonPage(
        limit: _tamanhoPagina,
        offset: 0,
      );
      emit(
        ListaPokemonSucesso(
          pokemons: pagina,
          temMais: pagina.length == _tamanhoPagina,
        ),
      );
    } catch (e) {
      emit(ListaPokemonErro(_mensagemDeErro(e)));
    }
  }

  String _mensagemDeErro(Object erro) {
    if (erro is PokeApiException) {
      return erro.isRateLimited
          ? 'Muitas requisições. Aguarde um instante e tente de novo.'
          : erro.message;
    }
    return 'Não foi possível carregar. Verifique sua conexão.';
  }
}
