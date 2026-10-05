String? _en(List list, String key) {
  for (final e in list) {
    if (e['language']?['name'] == 'en') {
      return (e[key] as String).replaceAll(RegExp(r'[\n\f]+'), ' ');
    }
  }
  return null;
}

/// Tipo de concurso (Cool, Beauty, Cute, Smart, Tough).
class ContestTypeInfo {
  final int id;
  final String name;
  final String? color; // cor em inglês, vinda de names (ex.: "Red")
  final String? berryFlavor; // ex.: "spicy"

  const ContestTypeInfo({
    required this.id,
    required this.name,
    required this.color,
    required this.berryFlavor,
  });

  factory ContestTypeInfo.fromJson(Map<String, dynamic> j) {
    String? color;
    for (final n in j['names'] as List) {
      if (n['language']?['name'] == 'en') color = n['color'] as String?;
    }
    return ContestTypeInfo(
      id: j['id'],
      name: j['name'],
      color: color,
      berryFlavor: j['berry_flavor']?['name'],
    );
  }
}

/// Berry com determinado sabor, e a potência dele.
class FlavorBerry {
  final String name; // ex.: "cheri"
  final int potency;
  const FlavorBerry({required this.name, required this.potency});
}

/// Efeito de concurso (normal ou Super Contest).
/// [jam] e [effect] só existem nos efeitos normais; [moves] só nos Super.
class ContestEffectInfo {
  final int id;
  final int? appeal;
  final int? jam;
  final String? effect;
  final String? flavor;
  final List<String> moves;

  const ContestEffectInfo({
    required this.id,
    required this.appeal,
    required this.jam,
    required this.effect,
    required this.flavor,
    required this.moves,
  });

  factory ContestEffectInfo.fromJson(Map<String, dynamic> j) =>
      ContestEffectInfo(
        id: j['id'],
        appeal: j['appeal'],
        jam: j['jam'],
        effect: _en((j['effect_entries'] ?? []) as List, 'effect'),
        flavor: _en((j['flavor_text_entries'] ?? []) as List, 'flavor_text'),
        moves: ((j['moves'] ?? []) as List)
            .map((e) => e['name'] as String)
            .toList(),
      );
}