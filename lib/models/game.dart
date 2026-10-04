/// Um jogo (versão) com os dados do seu grupo de versões.
class GameDetail {
  final int id;
  final String name; // ex.: "red"
  final String? displayName; // nome em inglês da API
  final String versionGroup; // ex.: "red-blue"
  final String generation; // ex.: "generation-i"
  final List<String> siblings; // jogos do mesmo grupo (inclui o próprio)
  final List<String> regions;
  final List<String> pokedexes;
  final List<String> moveLearnMethods;

  const GameDetail({
    required this.id,
    required this.name,
    required this.displayName,
    required this.versionGroup,
    required this.generation,
    required this.siblings,
    required this.regions,
    required this.pokedexes,
    required this.moveLearnMethods,
  });

  static List<String> _names(dynamic l) =>
      (l as List).map((e) => e['name'] as String).toList();

  factory GameDetail.fromJson(
      Map<String, dynamic> version, Map<String, dynamic> group) {
    String? en;
    for (final n in version['names'] as List) {
      if (n['language']?['name'] == 'en') en = n['name'];
    }
    return GameDetail(
      id: version['id'],
      name: version['name'],
      displayName: en,
      versionGroup: group['name'],
      generation: group['generation']['name'],
      siblings: _names(group['versions']),
      regions: _names(group['regions']),
      pokedexes: _names(group['pokedexes']),
      moveLearnMethods: _names(group['move_learn_methods']),
    );
  }
}