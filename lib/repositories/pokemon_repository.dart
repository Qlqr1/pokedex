import '../models/models.dart';
import '../services/pokeapi_service.dart';

/// Camada entre as telas e a PokéAPI.
///
/// Fluxo (como no PDF): existe no cache? Sim -> devolve do cache.
/// Não -> busca na PokéAPI, salva no cache e devolve.
///
/// O cache guarda o Future da requisição. Assim, se duas telas pedirem o mesmo
/// dado ao mesmo tempo, só uma requisição é feita. Requisições que falham NÃO
/// ficam no cache, então tentar de novo faz uma nova requisição.
///
/// Por enquanto o cache é só em memória (some ao fechar o app).
class PokemonRepository {
  /// Instância compartilhada, para o cache sobreviver entre telas.
  static final PokemonRepository shared = PokemonRepository();

  final PokeApiService _service;

  PokemonRepository({PokeApiService? service})
    : _service = service ?? PokeApiService();

  final Map<String, Future<NamedApiResourceList>> _lists = {};
  final Map<String, Future<Pokemon>> _pokemon = {};
  final Map<String, Future<PokemonSpecies>> _species = {};
  final Map<String, Future<PokemonForm>> _forms = {};
  final Map<String, Future<TypeInfo>> _types = {};
  final Map<String, Future<Ability>> _abilities = {};
  final Map<String, Future<Move>> _moves = {};
  final Map<String, Future<Item>> _items = {};
  final Map<int, Future<EvolutionChain>> _chains = {};
  final Map<String, Future<List<PokemonEncounter>>> _encounters = {};

  // ---------------------------------------------------------------------------
  // Listagens
  // ---------------------------------------------------------------------------

  /// Nome + URL de cada Pokémon da página (sem detalhes).
  Future<NamedApiResourceList> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) => getResourceList('pokemon', limit: limit, offset: offset);

  /// Listagem de qualquer grupo da API ('pokemon', 'type', 'item', ...).
  Future<NamedApiResourceList> getResourceList(
    String endpoint, {
    int limit = 20,
    int offset = 0,
  }) => _cached(
    _lists,
    '$endpoint:$limit:$offset',
    () => _service.getResourceList(endpoint, limit: limit, offset: offset),
  );

  /// Página com os detalhes completos de cada Pokémon, na ordem da Pokédex.
  /// Cada Pokémon fica no cache individualmente, então voltar para uma página
  /// já vista não faz nenhuma requisição.
  Future<List<Pokemon>> getPokemonPage({int limit = 20, int offset = 0}) async {
    final list = await getPokemonList(limit: limit, offset: offset);
    return Future.wait(list.results.map((r) => getPokemon(r.name)));
  }

  // ---------------------------------------------------------------------------
  // Endpoints principais
  // ---------------------------------------------------------------------------

  /// Pokémon por ID ou nome. Fica guardado sob as duas chaves.
  Future<Pokemon> getPokemon(Object idOrName) async {
    final pokemon = await _cached(
      _pokemon,
      _key(idOrName),
      () => _service.getPokemon(idOrName),
    );
    _pokemon.putIfAbsent('${pokemon.id}', () => Future.value(pokemon));
    _pokemon.putIfAbsent(pokemon.name, () => Future.value(pokemon));
    return pokemon;
  }

  Future<PokemonSpecies> getPokemonSpecies(Object idOrName) => _cached(
    _species,
    _key(idOrName),
    () => _service.getPokemonSpecies(idOrName),
  );

  Future<PokemonForm> getPokemonForm(Object idOrName) =>
      _cached(_forms, _key(idOrName), () => _service.getPokemonForm(idOrName));

  Future<TypeInfo> getType(Object idOrName) =>
      _cached(_types, _key(idOrName), () => _service.getType(idOrName));

  Future<Ability> getAbility(Object idOrName) =>
      _cached(_abilities, _key(idOrName), () => _service.getAbility(idOrName));

  Future<Move> getMove(Object idOrName) =>
      _cached(_moves, _key(idOrName), () => _service.getMove(idOrName));

  Future<Item> getItem(Object idOrName) =>
      _cached(_items, _key(idOrName), () => _service.getItem(idOrName));

  Future<EvolutionChain> getEvolutionChain(int id) =>
      _cached(_chains, id, () => _service.getEvolutionChain(id));

  /// Usa a URL que vem em PokemonSpecies.evolutionChain.
  Future<EvolutionChain> getEvolutionChainByUrl(String url) {
    final id = ApiResource(url: url).id;
    return id != null
        ? getEvolutionChain(id)
        : _service.getEvolutionChainByUrl(url);
  }

  Future<List<PokemonEncounter>> getPokemonEncounters(Object idOrName) =>
      _cached(
        _encounters,
        _key(idOrName),
        () => _service.getPokemonEncounters(idOrName),
      );

  // ---------------------------------------------------------------------------
  // Atalhos que combinam endpoints
  // ---------------------------------------------------------------------------

  /// Fraquezas, resistências e imunidades de um Pokémon, a partir dos seus tipos.
  /// Retorna multiplicador por tipo atacante (0, 0.25, 0.5, 1, 2, 4).
  Future<Map<String, double>> getDefenseMultipliers(Pokemon pokemon) async {
    final types = await Future.wait(pokemon.typeNames.map(getType));
    return calculateDefense(types);
  }

  /// Cadeia evolutiva de um Pokémon (via espécie).
  Future<EvolutionChain?> getEvolutionChainOf(Pokemon pokemon) async {
    final species = await getPokemonSpecies(pokemon.species.name);
    final chain = species.evolutionChain;
    return chain == null ? null : getEvolutionChainByUrl(chain.url);
  }

  // ---------------------------------------------------------------------------
  // Cache
  // ---------------------------------------------------------------------------

  /// Esvazia o cache (ex.: no "puxar para atualizar").
  void clearCache() {
    _lists.clear();
    _pokemon.clear();
    _species.clear();
    _forms.clear();
    _types.clear();
    _abilities.clear();
    _moves.clear();
    _items.clear();
    _chains.clear();
    _encounters.clear();
  }

  void dispose() => _service.dispose();

  // ---------------------------------------------------------------------------
  // Internos
  // ---------------------------------------------------------------------------

  String _key(Object idOrName) => idOrName.toString().trim().toLowerCase();

  Future<T> _cached<K, T>(
    Map<K, Future<T>> cache,
    K key,
    Future<T> Function() fetch,
  ) {
    final existing = cache[key];
    if (existing != null) return existing;

    final future = fetch();
    cache[key] = future;
    // Não guarda falhas: assim, tentar de novo faz uma nova requisição.
    // O erro continua chegando a quem chamou, pois devolvemos o próprio future.
    future.then<void>((_) {}, onError: (Object error) => cache.remove(key));
    return future;
  }
}
