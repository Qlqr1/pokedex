import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';
import '../models/named_ref.dart';

/// Pode migrar estes métodos para o PokeApiService se preferir.
class ItemService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> fetchItemList() async =>
      ((await _get('item?limit=3000'))['results'] as List)
          .map((e) => NamedRef.fromJson(e))
          .toList();

  Future<Item> fetchItem(String name) async =>
      Item.fromJson(await _get('item/$name'));
}