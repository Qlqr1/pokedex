import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/named_ref.dart';
import '../models/pokemon_extra.dart';

/// Pode migrar estes métodos para o PokeApiService se preferir.
class PokemonExtraService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> _list(String endpoint) async =>
      ((await _get('$endpoint?limit=100'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  Future<List<NamedRef>> fetchTypes() => _list('type');
  Future<List<NamedRef>> fetchStats() => _list('stat');
  Future<List<NamedRef>> fetchNatures() => _list('nature');
  Future<List<NamedRef>> fetchEggGroups() => _list('egg-group');
  Future<List<NamedRef>> fetchHabitats() => _list('pokemon-habitat');
  Future<List<NamedRef>> fetchPokeathlonStats() => _list('pokeathlon-stat');

  /// A listagem de características traz só a URL; devolvemos os ids.
  Future<List<int>> fetchCharacteristicIds() async {
    final results =
        (await _get('characteristic?limit=100'))['results'] as List;
    return results.map((e) {
      final parts =
          (e['url'] as String).split('/').where((p) => p.isNotEmpty).toList();
      return int.parse(parts.last);
    }).toList()
      ..sort();
  }

  Future<TypeInfo> fetchType(String n) async =>
      TypeInfo.fromJson(await _get('type/$n'));
  Future<StatInfo> fetchStat(String n) async =>
      StatInfo.fromJson(await _get('stat/$n'));
  Future<NatureInfo> fetchNature(String n) async =>
      NatureInfo.fromJson(await _get('nature/$n'));
  Future<SpeciesGroup> fetchEggGroup(String n) async =>
      SpeciesGroup.fromJson(await _get('egg-group/$n'));
  Future<SpeciesGroup> fetchHabitat(String n) async =>
      SpeciesGroup.fromJson(await _get('pokemon-habitat/$n'));
  Future<PokeathlonStatInfo> fetchPokeathlonStat(String n) async =>
      PokeathlonStatInfo.fromJson(await _get('pokeathlon-stat/$n'));
  Future<CharacteristicInfo> fetchCharacteristic(int id) async =>
      CharacteristicInfo.fromJson(await _get('characteristic/$id'));
}