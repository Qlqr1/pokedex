import '../utils/lang.dart';
import 'named_ref.dart';

class Item {
  final int id;
  final String name;
  final String? displayName;
  final int cost;
  final int? flingPower;
  final String? flingEffect;
  final String category;
  final List<String> attributes;
  final String? shortEffect;
  final String? effect;
  final String? flavorText;
  final String? spriteUrl;
  final List<NamedRef> heldBy;

  const Item({
    required this.id,
    required this.name,
    required this.displayName,
    required this.cost,
    required this.flingPower,
    required this.flingEffect,
    required this.category,
    required this.attributes,
    required this.shortEffect,
    required this.effect,
    required this.flavorText,
    required this.spriteUrl,
    required this.heldBy,
  });

  static String? _en(List list, String key) => Lang.pick(list, key);

  factory Item.fromJson(Map<String, dynamic> j) => Item(
        id: j['id'],
        name: j['name'],
        displayName: _en(j['names'] as List, 'name'),
        cost: j['cost'] ?? 0,
        flingPower: j['fling_power'],
        flingEffect: j['fling_effect']?['name'],
        category: j['category']?['name'] ?? '',
        attributes:
            (j['attributes'] as List).map((e) => e['name'] as String).toList(),
        shortEffect: _en(j['effect_entries'] as List, 'short_effect'),
        effect: _en(j['effect_entries'] as List, 'effect'),
        // do mais recente para o mais antigo
        flavorText:
            _en((j['flavor_text_entries'] as List).reversed.toList(), 'text'),
        spriteUrl: j['sprites']?['default'],
        heldBy: (j['held_by_pokemon'] as List)
            .map((e) => NamedRef.fromJson(e['pokemon']))
            .toList(),
      );
}
