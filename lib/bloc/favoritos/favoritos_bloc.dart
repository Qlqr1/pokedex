import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/favorito.dart';
import '../../repositories/favoritos_repository.dart';
import '../../services/pokedex_api_service.dart'; // ApiException
import 'favoritos_event.dart';
import 'favoritos_state.dart';

/// Controla os favoritos do usuário logado. Fica no topo da árvore de widgets
/// (main.dart), então o coração e a tela de Favoritos enxergam o mesmo estado.
class FavoritosBloc extends Bloc<FavoritosEvent, FavoritosState> {
  final FavoritosRepository _repository;

  FavoritosBloc({required FavoritosRepository repository})
    : _repository = repository,
      super(const FavoritosInicial()) {
    on<FavoritosIniciados>(_aoIniciar);
    on<FavoritosLimpos>((event, emit) => emit(const FavoritosInicial()));
    // sequential(): toques rápidos são processados um de cada vez.
    on<FavoritoAlternado>(_aoAlternar, transformer: sequential());
  }

  Future<void> _aoIniciar(
    FavoritosIniciados event,
    Emitter<FavoritosState> emit,
  ) async {
    emit(const FavoritosCarregando());
    try {
      emit(FavoritosSucesso(await _repository.listar()));
    } catch (e) {
      emit(_erro(e, 'Não foi possível carregar os favoritos.'));
    }
  }

  Future<void> _aoAlternar(
    FavoritoAlternado event,
    Emitter<FavoritosState> emit,
  ) async {
    final atual = state;
    if (atual is! FavoritosSucesso) return; // ainda carregando

    try {
      if (atual.contem(event.pokemonId)) {
        await _repository.remover(event.pokemonId);
        emit(
          FavoritosSucesso(
            atual.favoritos.where((f) => f.pokemonId != event.pokemonId).toList(),
          ),
        );
      } else {
        final novo = Favorito(pokemonId: event.pokemonId, nome: event.nome);
        await _repository.adicionar(novo);
        emit(FavoritosSucesso([...atual.favoritos, novo]));
      }
    } catch (e) {
      emit(_erro(e, 'Não foi possível salvar o favorito.'));
    }
  }

  FavoritosErro _erro(Object erro, String mensagemPadrao) {
    if (erro is ApiException) {
      return FavoritosErro(erro.message, sessaoExpirada: erro.statusCode == 401);
    }
    return FavoritosErro(mensagemPadrao);
  }
}