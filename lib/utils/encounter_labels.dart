import 'string_utils.dart';

const _methods = {
  'walk': 'Walk',
  'old-rod': 'Old Rod',
  'good-rod': 'Good Rod',
  'super-rod': 'Super Rod',
  'surf': 'Surf',
  'rock-smash': 'Rock Smash',
  'headbutt': 'Cabeçada',
  'gift': 'Presente',
  'gift-egg': 'Ovo de presente',
  'only-one': 'Único (estático)',
  'pokeflute': 'Poké Flauta',
  'sos-encounter': 'Chamada SOS',
  'roaming-grass': 'Errante (grama)',
  'roaming-water': 'Errante (água)',
};

String methodLabel(String m) => _methods[m] ?? m.pretty;

const _conditions = {
  'time-morning': 'Manhã',
  'time-day': 'Dia',
  'time-night': 'Noite',
  'swarm-yes': 'Enxame',
  'swarm-no': 'Sem enxame',
  'radar-on': 'Com Pokéradar',
  'radar-off': 'Sem Pokéradar',
  'radio-hoenn': 'Rádio de Hoenn',
  'radio-sinnoh': 'Rádio de Sinnoh',
  'radio-off': 'Rádio desligado',
  'season-spring': 'Primavera',
  'season-summer': 'Verão',
  'season-autumn': 'Outono',
  'season-winter': 'Inverno',
};

/// "time-day+swarm-no" -> "Dia + Sem enxame"
String conditionLabel(String key) => key
    .split('+')
    .map((c) => _conditions[c] ?? c.replaceFirst('starter-', 'Inicial: ').pretty)
    .join(' + ');

const _versionOrder = [
  'red', 'blue', 'yellow', 'gold', 'silver', 'crystal', 'ruby', 'sapphire',
  'emerald', 'firered', 'leafgreen', 'diamond', 'pearl', 'platinum',
  'heartgold', 'soulsilver', 'black', 'white', 'black-2', 'white-2', 'x', 'y',
  'omega-ruby', 'alpha-sapphire', 'sun', 'moon', 'ultra-sun', 'ultra-moon',
  'lets-go-pikachu', 'lets-go-eevee', 'sword', 'shield', 'the-isle-of-armor',
  'the-crown-tundra', 'brilliant-diamond', 'shining-pearl', 'legends-arceus',
  'scarlet', 'violet', 'the-teal-mask', 'the-indigo-disk',
];

/// Posição do jogo na ordem de lançamento (desconhecidos vão para o fim).
int versionRank(String v) {
  final i = _versionOrder.indexOf(v);
  return i == -1 ? _versionOrder.length : i;
}

/// Jogos em que a API não tem taxa real (todos aparecem com 100%).
bool versionHasNoRates(String v) =>
    v == 'lets-go-pikachu' || v == 'lets-go-eevee';