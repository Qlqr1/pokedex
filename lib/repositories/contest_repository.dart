import '../models/contest.dart';
import '../models/named_ref.dart';
import '../services/contest_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class ContestRepository {
  ContestRepository._();
  static final instance = ContestRepository._();

  final _service = ContestService();
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

  Future<List<NamedRef>> getContestTypes() =>
      _cached('types', _service.fetchContestTypes);
  Future<ContestTypeInfo> getContestType(String n) =>
      _cached('type/$n', () => _service.fetchContestType(n));
  Future<List<FlavorBerry>> getFlavorBerries(String flavor) =>
      _cached('flavor/$flavor', () => _service.fetchFlavorBerries(flavor));
  Future<List<ContestEffectInfo>> getContestEffects() =>
      _cached('effects', _service.fetchContestEffects);
  Future<List<ContestEffectInfo>> getSuperContestEffects() =>
      _cached('super-effects', _service.fetchSuperContestEffects);
}