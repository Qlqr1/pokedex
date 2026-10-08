import '../models/game.dart';
import '../models/named_ref.dart';
import '../services/game_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class GameRepository {
  GameRepository._();
  static final instance = GameRepository._();

  final _service = GameService();
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

  Future<List<NamedRef>> getGenerations() =>
      _cached('generations', _service.fetchGenerations);
  Future<List<NamedRef>> getGenerationGames(String gen) =>
      _cached('gen-games/$gen', () => _service.fetchGenerationGames(gen));
  Future<GameDetail> getGame(String name) =>
      _cached('game/$name', () => _service.fetchGame(name));

  /// Limpa os textos em cache (usado ao trocar de idioma).
  void clear() {
    _cache.clear();
  }
}
