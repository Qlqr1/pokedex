import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contest.dart';
import '../models/named_ref.dart';

/// Pode migrar estes métodos para o PokeApiService se preferir.
class ContestService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> fetchContestTypes() async =>
      ((await _get('contest-type?limit=100'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  Future<ContestTypeInfo> fetchContestType(String name) async =>
      ContestTypeInfo.fromJson(await _get('contest-type/$name'));

  Future<List<FlavorBerry>> fetchFlavorBerries(String flavor) async {
    final j = await _get('berry-flavor/$flavor');
    final list = (j['berries'] as List)
        .map((e) => FlavorBerry(
              name: e['berry']['name'],
              potency: e['potency'],
            ))
        .toList()
      ..sort((a, b) => b.potency.compareTo(a.potency));
    return list;
  }

  /// A listagem de efeitos traz só a URL (sem nome), então buscamos cada um
  /// (são poucos: ~30 efeitos normais e ~20 Super Contest).
  Future<List<ContestEffectInfo>> _fetchEffects(String endpoint) async {
    final results =
        (await _get('$endpoint?limit=100'))['results'] as List;
    final ids = results.map((e) {
      final parts =
          (e['url'] as String).split('/').where((p) => p.isNotEmpty).toList();
      return int.parse(parts.last);
    }).toList()
      ..sort();
    return Future.wait(ids.map((id) async =>
        ContestEffectInfo.fromJson(await _get('$endpoint/$id'))));
  }

  Future<List<ContestEffectInfo>> fetchContestEffects() =>
      _fetchEffects('contest-effect');
  Future<List<ContestEffectInfo>> fetchSuperContestEffects() =>
      _fetchEffects('super-contest-effect');
}