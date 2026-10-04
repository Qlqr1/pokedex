import 'named_ref.dart';

class PokedexEntry {
  final int number; // número dentro desta Pokédex
  final String speciesName;
  final int speciesId; // id da espécie = id do Pokémon padrão
  const PokedexEntry(
      {required this.number,
      required this.speciesName,
      required this.speciesId});
}

class PokedexDetail {
  final int id;
  final String name;
  final String? displayName;
  final String? description;
  final String? region;
  final bool isMainSeries;
  final List<String> versionGroups;
  final List<PokedexEntry> entries;

  const PokedexDetail({
    required this.id,
    required this.name,
    required this.displayName,
    required this.description,
    required this.region,
    required this.isMainSeries,
    required this.versionGroups,
    required this.entries,
  });

  static String? _en(List list, String key) {
    for (final e in list) {
      if (e['language']?['name'] == 'en') return e[key] as String;
    }
    return null;
  }

  factory PokedexDetail.fromJson(Map<String, dynamic> j) => PokedexDetail(
        id: j['id'],
        name: j['name'],
        displayName: _en(j['names'] as List, 'name'),
        description: _en(j['descriptions'] as List, 'description'),
        region: j['region']?['name'],
        isMainSeries: j['is_main_series'] ?? true,
        versionGroups: (j['version_groups'] as List)
            .map((e) => e['name'] as String)
            .toList(),
        entries: (j['pokemon_entries'] as List).map((e) {
          final species = NamedRef.fromJson(e['pokemon_species']);
          return PokedexEntry(
            number: e['entry_number'],
            speciesName: species.name,
            speciesId: species.id,
          );
        }).toList()
          ..sort((a, b) => a.number.compareTo(b.number)),
      );
}

/// Número do Pokémon em uma Pokédex.
class DexNumber {
  final String dex;
  final int number;
  const DexNumber({required this.dex, required this.number});
}

/// Texto da Pokédex, com os jogos em que ele aparece.
class DexText {
  final List<String> versions;
  final String text;
  const DexText({required this.versions, required this.text});
}

/// Dados de Pokédex de uma espécie: números nas dexes e textos por jogo.
class SpeciesDex {
  final List<DexNumber> numbers;
  final List<DexText> texts;
  const SpeciesDex({required this.numbers, required this.texts});

  factory SpeciesDex.fromJson(Map<String, dynamic> j) {
    final numbers = (j['pokedex_numbers'] as List)
        .map((e) => DexNumber(
              dex: e['pokedex']['name'],
              number: e['entry_number'],
            ))
        .toList();

    // Agrupa textos idênticos (muitos jogos repetem o mesmo texto).
    final byText = <String, List<String>>{};
    for (final e in j['flavor_text_entries'] as List) {
      if (e['language']?['name'] != 'en') continue;
      final text = (e['flavor_text'] as String)
          .replaceAll(RegExp(r'[\n\f\u00ad]+'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      final version = e['version']['name'] as String;
      final list = byText.putIfAbsent(text, () => []);
      if (!list.contains(version)) list.add(version);
    }
    final texts = byText.entries
        .map((e) => DexText(versions: e.value, text: e.key))
        .toList();
    return SpeciesDex(numbers: numbers, texts: texts);
  }
}