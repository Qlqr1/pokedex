import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/models.dart';
import '../../repositories/pokemon_repository.dart';
import '../../utils/search_utils.dart';
import 'busca_pokemon_event.dart';
import 'busca_pokemon_state.dart';

/// Controla a busca por nome ou número na lista de Pokémon.
///
/// Baixa a lista de nomes uma vez (na primeira busca) e filtra localmente a
/// cada mudança de texto. Os detalhes de cada resultado são carregados pela
/// tela, sob demanda.
class BuscaPokemonBloc extends Bloc<BuscaPokemonEvent, BuscaPokemonState> {
  /// Na PokéAPI, ids acima disso são formas alternativas (Mega, regionais...),
  /// que já aparecem no seletor de formas da página do Pokémon.
  static const int _maxSpeciesId = 10000;

  final PokemonRepository _repository;

  /// Lista de nomes já pedida (ou em andamento). Null = ainda não baixada.
  Future<List<NamedApiResource>>? _nomes;

  /// Último texto buscado, já normalizado.
  String _consulta = '';

  BuscaPokemonBloc({PokemonRepository? repository})
    : _repository = repository ?? PokemonRepository.shared,
      super(const BuscaPokemonInicial()) {
    on<BuscaPokemonTextoAlterado>(_aoAlterarTexto);
    on<BuscaPokemonNovaTentativa>((event, emit) => _buscar(emit));
    on<BuscaPokemonAtualizada>((event, emit) => _nomes = null);
  }

  Future<void> _aoAlterarTexto(
    BuscaPokemonTextoAlterado event,
    Emitter<BuscaPokemonState> emit,
  ) {
    _consulta = normalizeQuery(event.texto);
    return _buscar(emit);
  }

  Future<void> _buscar(Emitter<BuscaPokemonState> emit) async {
    final consulta = _consulta;

    if (consulta.isEmpty) {
      emit(const BuscaPokemonInicial());
      return;
    }

    // Só mostra "Carregando" se a lista de nomes ainda não foi pedida.
    if (_nomes == null) emit(const BuscaPokemonCarregando());
    final nomes = _nomes ??= _carregarNomes();

    try {
      final lista = await nomes;
      // O texto mudou (ou foi apagado) enquanto a lista carregava: este
      // resultado já está velho, então não emite nada.
      if (consulta != _consulta) return;

      emit(
        BuscaPokemonSucesso(
          lista.where((r) => matchesQuery(r.name, r.id, consulta)).toList(),
        ),
      );
    } catch (_) {
      _nomes = null; // permite tentar de novo com uma nova requisição
      if (consulta != _consulta) return;
      emit(
        const BuscaPokemonErro('Não foi possível carregar a lista para busca.'),
      );
    }
  }

  Future<List<NamedApiResource>> _carregarNomes() async {
    final pagina = await _repository.getResourceList(
      'pokemon',
      limit: 2000,
      offset: 0,
    );
    return pagina.results.where((r) => (r.id ?? 0) < _maxSpeciesId).toList();
  }
}
