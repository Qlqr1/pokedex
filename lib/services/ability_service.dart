import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ability.dart';

/// Pode colar estes métodos dentro do seu PokeApiService, se preferir.
class AbilityService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<List<NamedRef>> fetchAbilityList() async {
    final res = await http.get(Uri.parse('$_base/ability?limit=1000'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar habilidades (${res.statusCode})');
    }
    final results = (jsonDecode(res.body)['results'] as List);
    return results.map((e) => NamedRef.fromJson(e)).toList();
  }

  Future<Ability> fetchAbility(String idOrName) async {
    final res = await http.get(Uri.parse('$_base/ability/$idOrName'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar habilidade (${res.statusCode})');
    }
    return Ability.fromJson(jsonDecode(res.body));
  }
}