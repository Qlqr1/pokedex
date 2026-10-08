/// Idioma do endpoint /language/{id or name}.
class LanguageInfo {
  final int id;
  final String name; // ex.: "pt-br", "ja-hrkt"
  final String? iso639;
  final String? iso3166; // país, usado para a bandeira
  final bool official;
  final Map<String, String> names; // nome deste idioma, em cada idioma

  const LanguageInfo({
    required this.id,
    required this.name,
    required this.iso639,
    required this.iso3166,
    required this.official,
    required this.names,
  });

  factory LanguageInfo.fromJson(Map<String, dynamic> j) => LanguageInfo(
        id: j['id'],
        name: (j['name'] as String).toLowerCase(),
        iso639: j['iso639'],
        iso3166: j['iso3166'],
        official: j['official'] ?? false,
        names: {
          for (final n in (j['names'] ?? []) as List)
            (n['language']['name'] as String).toLowerCase(): n['name'] as String,
        },
      );

  /// Nome no próprio idioma (se a API tiver); senão em inglês.
  String get nativeName => names[name] ?? names['en'] ?? name;
  String get englishName => names['en'] ?? name;

  /// Bandeira a partir do código do país ("br" -> 🇧🇷).
  String get flag {
    final c = iso3166;
    if (c == null || c.length != 2) return '🌐';
    return String.fromCharCodes(
        c.toUpperCase().codeUnits.map((u) => 0x1F1E6 + (u - 65)));
  }
}
