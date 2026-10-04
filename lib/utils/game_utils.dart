import 'string_utils.dart';

const _roman = {
  'generation-i': 'I',
  'generation-ii': 'II',
  'generation-iii': 'III',
  'generation-iv': 'IV',
  'generation-v': 'V',
  'generation-vi': 'VI',
  'generation-vii': 'VII',
  'generation-viii': 'VIII',
  'generation-ix': 'IX',
};

/// "generation-iv" -> "Geração IV"
String generationLabel(String name) => _roman.containsKey(name)
    ? 'Geração ${_roman[name]}'
    : name.pretty;

const _games = {
  'firered': 'FireRed',
  'leafgreen': 'LeafGreen',
  'heartgold': 'HeartGold',
  'soulsilver': 'SoulSilver',
  'xd': 'XD',
  'lets-go-pikachu': "Let's Go, Pikachu!",
  'lets-go-eevee': "Let's Go, Eevee!",
  'legends-arceus': 'Legends: Arceus',
};

/// Nome do jogo para exibição ("omega-ruby" -> "Omega Ruby").
String gameLabel(String name) => _games[name] ?? name.pretty;