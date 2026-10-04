import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/machine.dart';
import '../models/named_ref.dart';
import '../utils/machine_utils.dart';

/// Na PokeAPI, o endpoint /machine só lista ids (sem nome) e cada machine é
/// "item + golpe + jogo". Por isso partimos dos itens do bolso "machines"
/// (tm01, hm01...) e buscamos o golpe de cada jogo ao abrir a página.
class MachineService {
  static const _base = 'https://pokeapi.co/api/v2';

  Future<dynamic> _get(String path) async {
    final res = await http.get(Uri.parse('$_base/$path'));
    if (res.statusCode != 200) {
      throw Exception('Erro ao carregar $path (${res.statusCode})');
    }
    return jsonDecode(res.body);
  }

  Future<List<NamedRef>> fetchMachineItems() async {
    final pocket = await _get('item-pocket/machines');
    final categories = (pocket['categories'] as List)
        .map((e) => NamedRef.fromJson(e))
        .toList();
    final lists = await Future.wait(categories.map((c) async {
      final cat = await _get('item-category/${c.name}');
      return (cat['items'] as List).map((e) => NamedRef.fromJson(e)).toList();
    }));
    final all = lists.expand((l) => l).toList()
      ..sort((a, b) => compareMachineNames(a.name, b.name));
    return all;
  }

  Future<MachineInfo> fetchMachine(String itemName) async {
    final item = await _get('item/$itemName');
    final entries = await Future.wait((item['machines'] as List).map((m) async {
      final id = (m['machine']['url'] as String)
          .split('/')
          .where((e) => e.isNotEmpty)
          .last;
      final machine = await _get('machine/$id');
      return MachineEntry(
        versionGroup: m['version_group']['name'],
        move: machine['move']['name'],
      );
    }));
    return MachineInfo(
      name: item['name'],
      spriteUrl: item['sprites']?['default'],
      entries: entries,
    );
  }
}