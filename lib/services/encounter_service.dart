import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/encounter_info.dart';
import '../models/named_ref.dart';

/// Pode migrar estes métodos para o PokeApiService se preferir.
class EncounterService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> _list(String path) async =>
      ((await _get('$path?limit=100'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  Future<List<NamedRef>> fetchMethods() => _list('encounter-method');
  Future<List<NamedRef>> fetchConditions() => _list('encounter-condition');

  Future<EncounterMethodInfo> fetchMethod(String name) async =>
      EncounterMethodInfo.fromJson(await _get('encounter-method/$name'));

  Future<EncounterConditionInfo> fetchCondition(String name) async =>
      EncounterConditionInfo.fromJson(await _get('encounter-condition/$name'));

  Future<ConditionValueInfo> fetchConditionValue(String name) async =>
      ConditionValueInfo.fromJson(
          await _get('encounter-condition-value/$name'));
}