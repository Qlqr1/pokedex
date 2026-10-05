import '../models/evolution_trigger.dart';
import '../models/named_ref.dart';
import '../services/evolution_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class EvolutionRepository {
  EvolutionRepository._();
  static final instance = EvolutionRepository._();

  final _service = EvolutionService();
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

  Future<List<NamedRef>> getTriggers() =>
      _cached('triggers', _service.fetchTriggers);
  Future<EvolutionTriggerInfo> getTrigger(String n) =>
      _cached('trigger/$n', () => _service.fetchTrigger(n));
}