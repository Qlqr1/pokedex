import '../utils/lang.dart';
import 'named_ref.dart';

String? _en(List list, String key) => Lang.pick(list, key);

class EncounterMethodInfo {
  final int id;
  final String name;
  final int order;
  final String? displayName;
  const EncounterMethodInfo(
      {required this.id,
      required this.name,
      required this.order,
      required this.displayName});

  factory EncounterMethodInfo.fromJson(Map<String, dynamic> j) =>
      EncounterMethodInfo(
        id: j['id'],
        name: j['name'],
        order: j['order'] ?? 0,
        displayName: _en(j['names'] as List, 'name'),
      );
}

class ConditionValueInfo {
  final int id;
  final String name;
  final String condition; // tipo: time, swarm...
  final String? displayName;
  const ConditionValueInfo(
      {required this.id,
      required this.name,
      required this.condition,
      required this.displayName});

  factory ConditionValueInfo.fromJson(Map<String, dynamic> j) =>
      ConditionValueInfo(
        id: j['id'],
        name: j['name'],
        condition: j['condition']['name'],
        displayName: _en(j['names'] as List, 'name'),
      );
}

class EncounterConditionInfo {
  final int id;
  final String name;
  final List<NamedRef> values;
  const EncounterConditionInfo(
      {required this.id, required this.name, required this.values});

  factory EncounterConditionInfo.fromJson(Map<String, dynamic> j) =>
      EncounterConditionInfo(
        id: j['id'],
        name: j['name'],
        values:
            (j['values'] as List).map((e) => NamedRef.fromJson(e)).toList(),
      );
}
