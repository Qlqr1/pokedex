import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/game.dart';
import '../models/named_ref.dart';

/// Pode migrar estes métodos para o PokeApiService se preferir.
class GameService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> fetchGenerations() async =>
      ((await _get('generation?limit=50'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  /// Jogos de uma geração: geração -> grupos de versões -> versões,
  /// na ordem de lançamento dos grupos.
  Future<List<NamedRef>> fetchGenerationGames(String generation) async {
    final gen = await _get('generation/$generation');
    final groups = await Future.wait((gen['version_groups'] as List)
        .map((g) => _get('version-group/${g['name']}')));
    groups.sort((a, b) => (a['order'] as int).compareTo(b['order'] as int));

    final seen = <String>{};
    final games = <NamedRef>[];
    for (final g in groups) {
      for (final v in g['versions'] as List) {
        final ref = NamedRef.fromJson(v);
        if (seen.add(ref.name)) games.add(ref);
      }
    }
    return games;
  }

  Future<GameDetail> fetchGame(String name) async {
    final version = await _get('version/$name');
    final group = await _get('version-group/${version['version_group']['name']}');
    return GameDetail.fromJson(version, group);
  }
}