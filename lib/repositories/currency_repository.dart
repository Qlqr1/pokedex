import '../models/currency.dart';
import '../services/currency_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class CurrencyRepository {
  CurrencyRepository._();
  static final instance = CurrencyRepository._();

  final _service = CurrencyService();
  Future<List<Currency>>? _list;

  Future<List<Currency>> getList() {
    final f = _list ??= _service.fetchCurrencies();
    f.then((_) {}, onError: (_) {
      _list = null;
    });
    return f;
  }
}