import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Erro lançado quando a PokéAPI responde com falha ou não responde.
class PokeApiException implements Exception {
  final String message;
  final int? statusCode;

  const PokeApiException(this.message, {this.statusCode});

  bool get isNotFound => statusCode == 404;
  bool get isRateLimited => statusCode == 429;

  @override
  String toString() => 'PokeApiException($statusCode): $message';
}

/// Responsável apenas por fazer as requisições HTTP e converter o JSON
/// nos models. Cache e regras de negócio ficam para o Repository.
class PokeApiService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const Duration _timeout = Duration(seconds: 15);

  final http.Client _client;

  /// Permite injetar um client falso nos testes.
  PokeApiService({http.Client? client}) : _client = client ?? http.Client();

  void dispose() => _client.close();

  // ---------------------------------------------------------------------------
  // Listagem (paginação com limit/offset)
  // ---------------------------------------------------------------------------

  /// /pokemon?limit=20&offset=0 -> só nome + url de cada Pokémon.
  Future<NamedApiResourceList> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final json = await _getJson('$baseUrl/pokemon?limit=$limit&offset=$offset');
    return NamedApiResourceList.fromJson(json);
  }

  /// Listagem de qualquer grupo da API (ex.: 'type', 'ability', 'move', 'item').
  /// Útil para a tela de grupos de endpoints.
  Future<NamedApiResourceList> getResourceList(
    String endpoint, {
    int limit = 20,
    int offset = 0,
  }) async {
    final json = await _getJson('$baseUrl/$endpoint?limit=$limit&offset=$offset');
    return NamedApiResourceList.fromJson(json);
  }

  /// Busca uma página já com os detalhes completos de cada Pokémon
  /// (nome, peso, altura, tipos e sprite), mantendo a ordem da Pokédex.
  /// A listagem não traz esses dados, então são feitas N requisições em paralelo.
  Future<List<Pokemon>> getPokemonPage({
    int limit = 20,
    int offset = 0,
  }) async {
    final list = await getPokemonList(limit: limit, offset: offset);
    return Future.wait(list.results.map((r) => getPokemonByUrl(r.url)));
  }

  // ---------------------------------------------------------------------------
  // Endpoints principais
  // ---------------------------------------------------------------------------

  /// /pokemon/{id ou nome}
  Future<Pokemon> getPokemon(Object idOrName) async =>
      Pokemon.fromJson(await _getJson('$baseUrl/pokemon/${_key(idOrName)}'));

  /// Mesmo que [getPokemon], mas a partir da URL de um [NamedApiResource].
  Future<Pokemon> getPokemonByUrl(String url) async =>
      Pokemon.fromJson(await _getJson(url));

  /// /pokemon-species/{id ou nome}
  Future<PokemonSpecies> getPokemonSpecies(Object idOrName) async =>
      PokemonSpecies.fromJson(
          await _getJson('$baseUrl/pokemon-species/${_key(idOrName)}'));

  /// /pokemon-form/{id ou nome}
  Future<PokemonForm> getPokemonForm(Object idOrName) async =>
      PokemonForm.fromJson(
          await _getJson('$baseUrl/pokemon-form/${_key(idOrName)}'));

  /// /type/{id ou nome}
  Future<TypeInfo> getType(Object idOrName) async =>
      TypeInfo.fromJson(await _getJson('$baseUrl/type/${_key(idOrName)}'));

  /// /ability/{id ou nome}
  Future<Ability> getAbility(Object idOrName) async =>
      Ability.fromJson(await _getJson('$baseUrl/ability/${_key(idOrName)}'));

  /// /move/{id ou nome}
  Future<Move> getMove(Object idOrName) async =>
      Move.fromJson(await _getJson('$baseUrl/move/${_key(idOrName)}'));

  /// /item/{id ou nome}
  Future<Item> getItem(Object idOrName) async =>
      Item.fromJson(await _getJson('$baseUrl/item/${_key(idOrName)}'));

  /// /evolution-chain/{id}
  Future<EvolutionChain> getEvolutionChain(int id) async =>
      EvolutionChain.fromJson(await _getJson('$baseUrl/evolution-chain/$id'));

  /// Mesmo que [getEvolutionChain], usando a URL que vem em
  /// PokemonSpecies.evolutionChain.
  Future<EvolutionChain> getEvolutionChainByUrl(String url) async =>
      EvolutionChain.fromJson(await _getJson(url));

  /// /pokemon/{id ou nome}/encounters (a resposta é uma lista JSON).
  Future<List<PokemonEncounter>> getPokemonEncounters(Object idOrName) async {
    final json = await _getJsonList(
        '$baseUrl/pokemon/${_key(idOrName)}/encounters');
    return json
        .map((e) => PokemonEncounter.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------------

  /// A API só aceita nomes em minúsculo.
  String _key(Object idOrName) =>
      Uri.encodeComponent(idOrName.toString().trim().toLowerCase());

  Future<Map<String, dynamic>> _getJson(String url) async =>
      await _request(url) as Map<String, dynamic>;

  Future<List<dynamic>> _getJsonList(String url) async =>
      await _request(url) as List<dynamic>;

  Future<dynamic> _request(String url) async {
    try {
      final response = await _client.get(Uri.parse(url)).timeout(_timeout);
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      throw PokeApiException(
        response.statusCode == 404
            ? 'Recurso não encontrado'
            : 'Falha na requisição',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      throw const PokeApiException('Tempo de resposta esgotado');
    } on PokeApiException {
      rethrow;
    } catch (e) {
      throw PokeApiException('Erro de conexão ou de leitura dos dados: $e');
    }
  }
}