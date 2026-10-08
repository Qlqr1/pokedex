import '../models/language.dart';
import '../services/language_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class LanguageRepository {
  LanguageRepository._();
  static final instance = LanguageRepository._();

  final _service = LanguageService();
  Future<List<LanguageInfo>>? _list;

  Future<List<LanguageInfo>> getLanguages() {
    final f = _list ??= _service.fetchLanguages();
    f.then((_) {}, onError: (_) {
      _list = null;
    });
    return f;
  }
}
