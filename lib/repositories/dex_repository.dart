import '../models/dex.dart';
import '../models/named_ref.dart';
import '../services/dex_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class DexRepository {
  DexRepository._();
  static final instance = DexRepository._();

  final _service = DexService();
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

  Future<List<NamedRef>> getPokedexList() =>
      _cached('pokedexes', _service.fetchPokedexList);
  Future<PokedexDetail> getPokedex(String name) =>
      _cached('pokedex/$name', () => _service.fetchPokedex(name));
  Future<SpeciesDex> getSpeciesDex(String speciesName) =>
      _cached('species-dex/$speciesName',
          () => _service.fetchSpeciesDex(speciesName));
}