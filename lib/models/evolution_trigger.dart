import 'named_ref.dart';

class EvolutionTriggerInfo {
  final int id;
  final String name;
  final String? displayName;
  final List<NamedRef> species; // espécies que resultam deste gatilho

  const EvolutionTriggerInfo({
    required this.id,
    required this.name,
    required this.displayName,
    required this.species,
  });

  factory EvolutionTriggerInfo.fromJson(Map<String, dynamic> j) {
    String? en;
    for (final n in j['names'] as List) {
      if (n['language']?['name'] == 'en') en = n['name'];
    }
    return EvolutionTriggerInfo(
      id: j['id'],
      name: j['name'],
      displayName: en,
      species: (j['pokemon_species'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList(),
    );
  }
}