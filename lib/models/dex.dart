import '../utils/lang.dart';
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

  static String? _en(List list, String key) => Lang.pick(list, key);

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

/// Dados da espécie vindos de /pokemon-species: números nas Pokédexes e
/// textos por jogo, além de grupos de ovo, gênero, crescimento e habitat.
class SpeciesDex {
  final List<DexNumber> numbers;
  final List<DexText> texts;
  final List<String> eggGroups;
  final int genderRate; // -1 = sem gênero; 0..8 = oitavos de chance de fêmea
  final String? growthRate;
  final String? habitat;
  final String? speciesName; // nome da espécie no idioma escolhido

  const SpeciesDex({
    required this.numbers,
    required this.texts,
    required this.eggGroups,
    required this.genderRate,
    required this.growthRate,
    required this.habitat,
    required this.speciesName,
  });

  factory SpeciesDex.fromJson(Map<String, dynamic> j) {
    final numbers = (j['pokedex_numbers'] as List)
        .map((e) => DexNumber(
              dex: e['pokedex']['name'],
              number: e['entry_number'],
            ))
        .toList();

    // Agrupa textos idênticos (muitos jogos repetem o mesmo texto).
    final byText = <String, List<String>>{};
    final entries = j['flavor_text_entries'] as List;
    final textLang =
        Lang.has(entries, Lang.code) ? Lang.code : Lang.fallback;
    for (final e in entries) {
      if ((e['language']?['name'] as String?)?.toLowerCase() != textLang) {
        continue;
      }
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
    return SpeciesDex(
      numbers: numbers,
      texts: texts,
      eggGroups: ((j['egg_groups'] ?? []) as List)
          .map((e) => e['name'] as String)
          .toList(),
      genderRate: j['gender_rate'] ?? -1,
      growthRate: j['growth_rate']?['name'],
      habitat: j['habitat']?['name'],
      speciesName: Lang.pick((j['names'] ?? []) as List, 'name'),
    );
  }
}
