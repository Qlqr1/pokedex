import '../models/location.dart';
import '../services/location_service.dart';
import '../models/named_ref.dart';

/// Cache em memória: voltar para uma tela já vista é instantâneo.
class LocationRepository {
  LocationRepository._();
  static final instance = LocationRepository._();

  final _service = LocationService();
  final Map<String, Future<Object>> _cache = {};

  Future<T> _cached<T extends Object>(String key, Future<T> Function() load) {
    final existing = _cache[key];
    if (existing != null) return existing as Future<T>;
    final f = load();
    _cache[key] = f;
    // Se falhar, não guarda o erro: permite "Tentar novamente".
    f.then((_) {}, onError: (_) {
      _cache.remove(key);
    });
    return f;
  }

  Future<List<NamedRef>> getRegions() =>
      _cached('regions', _service.fetchRegions);
  Future<Region> getRegion(String n) =>
      _cached('region/$n', () => _service.fetchRegion(n));
  Future<LocationInfo> getLocation(String n) =>
      _cached('location/$n', () => _service.fetchLocation(n));
  Future<LocationArea> getLocationArea(String n) =>
      _cached('area/$n', () => _service.fetchLocationArea(n));
  Future<List<NamedRef>> getPalParkAreas() =>
      _cached('pal-park-areas', _service.fetchPalParkAreas);
  Future<PalParkArea> getPalParkArea(String n) =>
      _cached('pal-park/$n', () => _service.fetchPalParkArea(n));
  Future<List<PokemonAreaEncounter>> getPokemonEncounters(int pokemonId) =>
      _cached('pokemon-enc/$pokemonId',
          () => _service.fetchPokemonEncounters(pokemonId));
}