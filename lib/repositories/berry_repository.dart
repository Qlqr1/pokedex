import '../models/berry.dart';
import '../models/named_ref.dart';
import '../services/berry_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class BerryRepository {
  BerryRepository._();
  static final instance = BerryRepository._();

  final _service = BerryService();
  Future<List<NamedRef>>? _list;
  final Map<String, Future<BerryDetail>> _berries = {};

  Future<List<NamedRef>> getList() {
    final f = _list ??= _service.fetchBerryList();
    f.then((_) {}, onError: (_) {
      _list = null;
    });
    return f;
  }

  Future<BerryDetail> getBerry(String name) {
    final f = _berries.putIfAbsent(name, () => _service.fetchBerry(name));
    f.then((_) {}, onError: (_) {
      _berries.remove(name);
    });
    return f;
  }
}