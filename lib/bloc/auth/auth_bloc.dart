import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/sessao.dart';
import '../../repositories/auth_repository.dart';
import '../../services/pokedex_api_service.dart'; // ApiException
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
    : _repository = repository,
      super(const AuthInicial()) {
    on<AuthIniciada>(_aoIniciar);
    on<AuthEntrarSolicitado>(
      (event, emit) =>
          _autenticar(emit, () => _repository.entrar(event.usuario, event.senha)),
    );
    on<AuthRegistrarSolicitado>(
      (event, emit) => _autenticar(
        emit,
        () => _repository.registrar(event.usuario, event.senha),
      ),
    );
    on<AuthSairSolicitado>(_aoSair);
  }

  Future<void> _aoIniciar(AuthIniciada event, Emitter<AuthState> emit) async {
    try {
      final sessao = await _repository.restaurar();
      emit(
        sessao == null ? const AuthDeslogado() : AuthAutenticado(sessao.usuario),
      );
    } catch (_) {
      emit(const AuthDeslogado());
    }
  }

  Future<void> _autenticar(
    Emitter<AuthState> emit,
    Future<Sessao> Function() acao,
  ) async {
    if (state is AuthCarregando) return; // evita envio duplo
    emit(const AuthCarregando());
    try {
      final sessao = await acao();
      emit(AuthAutenticado(sessao.usuario));
    } catch (e) {
      emit(
        AuthErro(
          e is ApiException
              ? e.message
              : 'Não foi possível entrar. Tente novamente.',
        ),
      );
    }
  }

  Future<void> _aoSair(AuthSairSolicitado event, Emitter<AuthState> emit) async {
    await _repository.sair();
    emit(const AuthDeslogado());
  }
}