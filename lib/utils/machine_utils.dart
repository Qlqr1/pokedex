import 'string_utils.dart';

/// "tm01" -> "TM01"
String machineLabel(String name) => name.toUpperCase();

final RegExp _machineName = RegExp(r'^(tm|hm|tr)(\d+)$');

/// Ordena TM, depois HM, depois TR; dentro de cada um, pelo número.
int compareMachineNames(String a, String b) {
  const prefixRank = {'tm': 0, 'hm': 1, 'tr': 2};
  final ma = _machineName.firstMatch(a);
  final mb = _machineName.firstMatch(b);
  if (ma == null || mb == null) {
    if (ma == null && mb == null) return a.compareTo(b);
    return ma == null ? 1 : -1;
  }
  final p = prefixRank[ma.group(1)]!.compareTo(prefixRank[mb.group(1)]!);
  if (p != 0) return p;
  return int.parse(ma.group(2)!).compareTo(int.parse(mb.group(2)!));
}

const _versionGroupLabels = {
  'red-blue': 'Red / Blue',
  'yellow': 'Yellow',
  'gold-silver': 'Gold / Silver',
  'crystal': 'Crystal',
  'ruby-sapphire': 'Ruby / Sapphire',
  'emerald': 'Emerald',
  'firered-leafgreen': 'FireRed / LeafGreen',
  'diamond-pearl': 'Diamond / Pearl',
  'platinum': 'Platinum',
  'heartgold-soulsilver': 'HeartGold / SoulSilver',
  'black-white': 'Black / White',
  'colosseum': 'Colosseum',
  'xd': 'XD',
  'black-2-white-2': 'Black 2 / White 2',
  'x-y': 'X / Y',
  'omega-ruby-alpha-sapphire': 'Omega Ruby / Alpha Sapphire',
  'sun-moon': 'Sun / Moon',
  'ultra-sun-ultra-moon': 'Ultra Sun / Ultra Moon',
  'lets-go-pikachu-lets-go-eevee': "Let's Go Pikachu / Eevee",
  'sword-shield': 'Sword / Shield',
  'the-isle-of-armor': 'The Isle of Armor',
  'the-crown-tundra': 'The Crown Tundra',
  'brilliant-diamond-and-shining-pearl': 'Brilliant Diamond / Shining Pearl',
  'legends-arceus': 'Legends: Arceus',
  'scarlet-violet': 'Scarlet / Violet',
  'the-teal-mask': 'The Teal Mask',
  'the-indigo-disk': 'The Indigo Disk',
};

String versionGroupLabel(String name) =>
    _versionGroupLabels[name] ?? name.pretty;

/// Posição na ordem de lançamento (desconhecidos vão para o fim).
int versionGroupRank(String name) {
  final i = _versionGroupLabels.keys.toList().indexOf(name);
  return i == -1 ? _versionGroupLabels.length : i;
}