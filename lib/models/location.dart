import 'named_ref.dart';

List<NamedRef> _refs(dynamic l) =>
    (l as List).map((e) => NamedRef.fromJson(e)).toList();

class Region {
  final String name;
  final List<NamedRef> locations;
  const Region({required this.name, required this.locations});

  factory Region.fromJson(Map<String, dynamic> j) =>
      Region(name: j['name'], locations: _refs(j['locations']));
}

class LocationInfo {
  final String name;
  final String? regionName;
  final List<NamedRef> areas;
  const LocationInfo(
      {required this.name, required this.regionName, required this.areas});

  factory LocationInfo.fromJson(Map<String, dynamic> j) => LocationInfo(
        name: j['name'],
        regionName: j['region']?['name'],
        areas: _refs(j['areas']),
      );
}

class EncounterDetail {
  final int minLevel;
  final int maxLevel;
  final int chance;
  final String method;
  final List<String> conditions; // ex.: time-morning, swarm-yes

  const EncounterDetail({
    required this.minLevel,
    required this.maxLevel,
    required this.chance,
    required this.method,
    required this.conditions,
  });

  factory EncounterDetail.fromJson(Map<String, dynamic> j) => EncounterDetail(
        minLevel: j['min_level'],
        maxLevel: j['max_level'],
        chance: j['chance'],
        method: j['method']['name'],
        conditions: ((j['condition_values'] ?? []) as List)
            .map((e) => e['name'] as String)
            .toList(),
      );
}

class VersionEncounter {
  final String version;
  final int maxChance;
  final List<EncounterDetail> details;
  const VersionEncounter(
      {required this.version, required this.maxChance, required this.details});

  factory VersionEncounter.fromJson(Map<String, dynamic> j) => VersionEncounter(
        version: j['version']['name'],
        maxChance: j['max_chance'],
        details: (j['encounter_details'] as List)
            .map((e) => EncounterDetail.fromJson(e))
            .toList(),
      );
}

/// Resumo dos encontros de um Pokémon (numa versão ou em todas).
/// [methodChances]: método -> chance (%) ou null quando o dado não é confiável.
class EncounterSummary {
  final int minLevel;
  final int maxLevel;
  final Map<String, int?> methodChances;
  const EncounterSummary(
      {required this.minLevel,
      required this.maxLevel,
      required this.methodChances});

  /// Maior chance conhecida (para ordenar); -1 se nenhuma.
  int get bestChance {
    var best = -1;
    for (final c in methodChances.values) {
      if (c != null && c > best) best = c;
    }
    return best;
  }
}

/// Métodos em que 100% é um valor legítimo.
const _guaranteedMethods = {'gift', 'gift-egg', 'only-one'};

class AreaEncounter {
  final NamedRef pokemon;
  final List<VersionEncounter> versions;
  const AreaEncounter({required this.pokemon, required this.versions});

  factory AreaEncounter.fromJson(Map<String, dynamic> j) => AreaEncounter(
        pokemon: NamedRef.fromJson(j['pokemon']),
        versions: (j['version_details'] as List)
            .map((e) => VersionEncounter.fromJson(e))
            .toList(),
      );

  /// Chance real de um método numa versão. A PokeAPI lista uma entrada por
  /// nível/condição (manhã, dia, noite...), então somar tudo passa de 100%.
  /// Aqui: entradas sem condição somam sempre; entradas com condição só
  /// somam dentro do mesmo grupo de condições, e vale o maior grupo.
  static int _methodChance(List<EncounterDetail> ds) {
    var base = 0;
    final groups = <String, int>{};
    for (final d in ds) {
      if (d.conditions.isEmpty) {
        base += d.chance;
      } else {
        final key = (List.of(d.conditions)..sort()).join('+');
        groups[key] = (groups[key] ?? 0) + d.chance;
      }
    }
    final extra = groups.isEmpty
        ? 0
        : groups.values.reduce((a, b) => a > b ? a : b);
    final total = base + extra;
    return total > 100 ? 100 : total;
  }

  /// [version] null = todas as versões. Retorna null se não ocorre nela.
  /// [unreliable]: pares "versão|método" cujo percentual não deve ser exibido.
  EncounterSummary? summaryFor(String? version,
      {Set<String> unreliable = const {}}) {
    int? minL, maxL;
    final chances = <String, int?>{};
    for (final v in versions) {
      if (version != null && v.version != version) continue;
      final byMethod = <String, List<EncounterDetail>>{};
      for (final d in v.details) {
        if (minL == null || d.minLevel < minL) minL = d.minLevel;
        if (maxL == null || d.maxLevel > maxL) maxL = d.maxLevel;
        byMethod.putIfAbsent(d.method, () => []).add(d);
      }
      byMethod.forEach((method, ds) {
        final c = unreliable.contains('${v.version}|$method')
            ? null
            : _methodChance(ds);
        final old = chances[method];
        if (!chances.containsKey(method)) {
          chances[method] = c;
        } else if (c != null && (old == null || c > old)) {
          chances[method] = c;
        }
      });
    }
    if (minL == null || maxL == null) return null;
    return EncounterSummary(
        minLevel: minL, maxLevel: maxL, methodChances: chances);
  }
}

class LocationArea {
  final String name;
  final String locationName;
  final List<String> encounterMethods;
  final List<AreaEncounter> encounters;

  LocationArea({
    required this.name,
    required this.locationName,
    required this.encounterMethods,
    required this.encounters,
  });

  factory LocationArea.fromJson(Map<String, dynamic> j) => LocationArea(
        name: j['name'],
        locationName: j['location']['name'],
        encounterMethods: (j['encounter_method_rates'] as List)
            .map((e) => e['encounter_method']['name'] as String)
            .toList(),
        encounters: (j['pokemon_encounters'] as List)
            .map((e) => AreaEncounter.fromJson(e))
            .toList(),
      );

  /// Pares "versão|método" em que 2+ Pokémon têm 100% (ex.: Let's Go, onde a
  /// API não tem taxa real). Nesses casos o percentual não é exibido.
  late final Set<String> unreliableChances = _findUnreliable();

  Set<String> _findUnreliable() {
    final counts = <String, int>{};
    for (final e in encounters) {
      final seen = <String>{};
      for (final v in e.versions) {
        for (final d in v.details) {
          if (d.chance >= 100 && !_guaranteedMethods.contains(d.method)) {
            seen.add('${v.version}|${d.method}');
          }
        }
      }
      for (final k in seen) {
        counts[k] = (counts[k] ?? 0) + 1;
      }
    }
    return {
      for (final en in counts.entries)
        if (en.value >= 2) en.key
    };
  }

  /// Versões (jogos) em que algum encontro aparece.
  List<String> get versions {
    final set = <String>{};
    for (final e in encounters) {
      for (final v in e.versions) {
        set.add(v.version);
      }
    }
    return set.toList()..sort();
  }
}

class PalParkEncounter {
  final NamedRef species;
  final int baseScore;
  final int rate;
  const PalParkEncounter(
      {required this.species, required this.baseScore, required this.rate});

  factory PalParkEncounter.fromJson(Map<String, dynamic> j) => PalParkEncounter(
        species: NamedRef.fromJson(j['pokemon_species']),
        baseScore: j['base_score'],
        rate: j['rate'],
      );
}

class PalParkArea {
  final String name;
  final List<PalParkEncounter> encounters;
  const PalParkArea({required this.name, required this.encounters});

  factory PalParkArea.fromJson(Map<String, dynamic> j) => PalParkArea(
        name: j['name'],
        encounters: (j['pokemon_encounters'] as List)
            .map((e) => PalParkEncounter.fromJson(e))
            .toList(),
      );
}

/// Encontro de um Pokémon numa área (endpoint /pokemon/{id}/encounters).
class PokemonEncounter {
  final NamedRef locationArea;
  final List<VersionEncounter> versions;
  const PokemonEncounter({required this.locationArea, required this.versions});

  factory PokemonEncounter.fromJson(Map<String, dynamic> j) => PokemonEncounter(
        locationArea: NamedRef.fromJson(j['location_area']),
        versions: (j['version_details'] as List)
            .map((e) => VersionEncounter.fromJson(e))
            .toList(),
      );
}

/// Um local onde o Pokémon aparece (resposta de /pokemon/{id}/encounters).
class PokemonAreaEncounter {
  final NamedRef area;
  final List<VersionEncounter> versions;
  const PokemonAreaEncounter({required this.area, required this.versions});

  factory PokemonAreaEncounter.fromJson(Map<String, dynamic> j) =>
      PokemonAreaEncounter(
        area: NamedRef.fromJson(j['location_area']),
        versions: (j['version_details'] as List)
            .map((e) => VersionEncounter.fromJson(e))
            .toList(),
      );
}

/// Uma linha de chance: [condition] é a chave crua (ex.: "time-night" ou
/// "time-day+swarm-yes"); null = vale em qualquer condição.
/// [chance] null = percentual não confiável (não exibir).
class ChanceLine {
  final String? condition;
  final int? chance;
  const ChanceLine(this.condition, this.chance);
}

class MethodInfo {
  final String method;
  final int minLevel;
  final int maxLevel;
  final List<ChanceLine> lines;
  const MethodInfo({
    required this.method,
    required this.minLevel,
    required this.maxLevel,
    required this.lines,
  });
}

/// Agrupa os detalhes de um encontro por método e por condição.
/// Entradas sem condição somam sempre; as com condição somam só dentro do
/// mesmo grupo (manhã/dia/noite...). Nunca passa de 100%.
List<MethodInfo> buildMethodInfos(List<EncounterDetail> details,
    {bool hideChance = false}) {
  final byMethod = <String, List<EncounterDetail>>{};
  for (final d in details) {
    byMethod.putIfAbsent(d.method, () => []).add(d);
  }
  int? cap(int v) => hideChance ? null : (v > 100 ? 100 : v);

  final result = <MethodInfo>[];
  byMethod.forEach((method, ds) {
    var minL = ds.first.minLevel;
    var maxL = ds.first.maxLevel;
    var base = 0;
    final groups = <String, int>{};
    for (final d in ds) {
      if (d.minLevel < minL) minL = d.minLevel;
      if (d.maxLevel > maxL) maxL = d.maxLevel;
      if (d.conditions.isEmpty) {
        base += d.chance;
      } else {
        final key = (List.of(d.conditions)..sort()).join('+');
        groups[key] = (groups[key] ?? 0) + d.chance;
      }
    }
    final lines = <ChanceLine>[];
    if (groups.isEmpty) {
      lines.add(ChanceLine(null, cap(base)));
    } else {
      final keys = groups.keys.toList()..sort();
      for (final k in keys) {
        lines.add(ChanceLine(k, cap(base + groups[k]!)));
      }
    }
    result.add(MethodInfo(
        method: method, minLevel: minL, maxLevel: maxL, lines: lines));
  });
  result.sort((a, b) => a.method.compareTo(b.method));
  return result;
}