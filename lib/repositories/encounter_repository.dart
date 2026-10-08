import '../models/encounter_info.dart';
import '../models/named_ref.dart';
import '../services/encounter_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class EncounterRepository {
  EncounterRepository._();
  static final instance = EncounterRepository._();

  final _service = EncounterService();
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

  Future<List<NamedRef>> getMethods() =>
      _cached('methods', _service.fetchMethods);
  Future<List<NamedRef>> getConditions() =>
      _cached('conditions', _service.fetchConditions);
  Future<EncounterMethodInfo> getMethod(String n) =>
      _cached('method/$n', () => _service.fetchMethod(n));
  Future<EncounterConditionInfo> getCondition(String n) =>
      _cached('condition/$n', () => _service.fetchCondition(n));
  Future<ConditionValueInfo> getConditionValue(String n) =>
      _cached('value/$n', () => _service.fetchConditionValue(n));

  /// Limpa os textos em cache (usado ao trocar de idioma).
  void clear() {
    _cache.clear();
  }
}
