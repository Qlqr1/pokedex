import '../models/favorito.dart';
import '../services/pokedex_api_service.dart';
import 'auth_repository.dart';
import 'favoritos_repository.dart';

/// Favoritos guardados na API própria, sempre do usuário logado.
class FavoritosApiRepository implements FavoritosRepository {
  final PokedexApiService _api;
  final AuthRepository _auth;

  FavoritosApiRepository({
    required PokedexApiService api,
    required AuthRepository auth,
  }) : _api = api,
       _auth = auth;

  String get _token =>
      _auth.token ??
      (throw const ApiException(
        'Faça login para usar os favoritos.',
        statusCode: 401,
      ));

  @override
  Future<List<Favorito>> listar() => _api.listarFavoritos(_token);

  @override
  Future<void> adicionar(Favorito favorito) async {
    try {
      await _api.adicionarFavorito(_token, favorito);
    } on ApiException catch (e) {
      // 409 = já estava nos favoritos: o resultado desejado já existe.
      if (e.statusCode != 409) rethrow;
    }
  }

  @override
  Future<void> remover(int pokemonId) => _api.removerFavorito(_token, pokemonId);
}