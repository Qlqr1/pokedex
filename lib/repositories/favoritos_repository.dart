import '../models/favorito.dart';

/// Contrato dos favoritos. Hoje há só a versão local; a versão que fala com a
/// API Flask pode ser escrita depois sem alterar o BLoC nem as telas.
abstract class FavoritosRepository {
  Future<List<Favorito>> listar();
  Future<void> adicionar(Favorito favorito);
  Future<void> remover(int pokemonId);
}