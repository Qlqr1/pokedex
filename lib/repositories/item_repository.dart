import '../models/item.dart';
import '../models/named_ref.dart';
import '../services/item_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class ItemRepository {
  ItemRepository._();
  static final instance = ItemRepository._();

  final _service = ItemService();
  Future<List<NamedRef>>? _list;
  final Map<String, Future<Item>> _items = {};

  Future<List<NamedRef>> getList() {
    final f = _list ??= _service.fetchItemList();
    f.then((_) {}, onError: (_) {
      _list = null;
    });
    return f;
  }

  Future<Item> getItem(String name) {
    final f = _items.putIfAbsent(name, () => _service.fetchItem(name));
    f.then((_) {}, onError: (_) {
      _items.remove(name);
    });
    return f;
  }

  /// Limpa os textos em cache (usado ao trocar de idioma).
  void clear() {
    _items.clear();
  }
}
