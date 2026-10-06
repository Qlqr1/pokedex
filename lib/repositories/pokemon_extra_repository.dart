import '../models/named_ref.dart';
import '../models/pokemon_extra.dart';
import '../services/pokemon_extra_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class PokemonExtraRepository {
  PokemonExtraRepository._();
  static final instance = PokemonExtraRepository._();

  final _s = PokemonExtraService();
  final Map<String, Future<Object>> _cache = {};

  Future<T> _cached<T extends Object>(String key, Future<T> Function() load) {
    final existing = _cache[key];
    if (existing != null) return existing as Future<T>;
    final f = load();
    _cache[key] = f;
    f.then((_) {}, onError: (_) {
      _cache.remove(key);
    });
    return f;
  }

  Future<List<NamedRef>> getTypes() => _cached('types', _s.fetchTypes);
  Future<List<NamedRef>> getStats() => _cached('stats', _s.fetchStats);
  Future<List<NamedRef>> getEggGroups() =>
      _cached('egg-groups', _s.fetchEggGroups);
  Future<List<NamedRef>> getHabitats() =>
      _cached('habitats', _s.fetchHabitats);
  Future<List<NamedRef>> getPokeathlonStats() =>
      _cached('pokeathlon', _s.fetchPokeathlonStats);

  Future<TypeInfo> getType(String n) =>
      _cached('type/$n', () => _s.fetchType(n));
  Future<StatInfo> getStat(String n) =>
      _cached('stat/$n', () => _s.fetchStat(n));
  Future<NatureInfo> getNature(String n) =>
      _cached('nature/$n', () => _s.fetchNature(n));
  Future<SpeciesGroup> getEggGroup(String n) =>
      _cached('egg-group/$n', () => _s.fetchEggGroup(n));
  Future<SpeciesGroup> getHabitat(String n) =>
      _cached('habitat/$n', () => _s.fetchHabitat(n));
  Future<PokeathlonStatInfo> getPokeathlonStat(String n) =>
      _cached('pokeathlon/$n', () => _s.fetchPokeathlonStat(n));

  /// Todas as naturezas com detalhes (~25 requisições, em paralelo).
  Future<List<NatureInfo>> getNatures() =>
      _cached('natures-all', () async {
        final refs = await _cached('natures', _s.fetchNatures);
        return Future.wait(refs.map((r) => getNature(r.name)));
      });

  /// Todas as características com detalhes (~30 requisições, em paralelo).
  Future<List<CharacteristicInfo>> getCharacteristics() =>
      _cached('characteristics-all', () async {
        final ids = await _s.fetchCharacteristicIds();
        return Future.wait(ids.map((id) => _cached(
            'characteristic/$id', () => _s.fetchCharacteristic(id))));
      });
}