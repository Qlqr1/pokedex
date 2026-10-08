/// Idioma atual do conteúdo vindo da PokéAPI e a escolha de texto traduzido.
///
/// [code] é o `name` de um idioma do endpoint /language (ex.: "en", "pt-br",
/// "ja", "zh-hans"). Quando a PokéAPI não tem o texto no idioma escolhido,
/// usamos o inglês.
class Lang {
  Lang._();

  static String code = 'en';
  static const String fallback = 'en';

  static String clean(String s) => s
      .replaceAll(RegExp(r'[\n\f\u00ad]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  /// Em uma lista de `{language: {name}, <key>: texto}`, devolve o texto do
  /// idioma atual (primeira ocorrência) ou, na falta dele, o do inglês.
  /// Para pegar o texto mais recente de uma lista cronológica (flavor texts),
  /// passe a lista invertida.
  static String? pick(List? list, String key) {
    if (list == null) return null;
    String? fallbackText;
    for (final e in list) {
      final v = e[key];
      if (v is! String) continue;
      final lang = (e['language']?['name'] as String?)?.toLowerCase();
      if (lang == code) return clean(v);
      if (lang == fallback && fallbackText == null) fallbackText = clean(v);
    }
    return fallbackText;
  }

  /// Existe algum texto neste idioma na lista?
  static bool has(List list, String lang) => list.any(
      (e) => (e['language']?['name'] as String?)?.toLowerCase() == lang);
}
