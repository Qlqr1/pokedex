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
  'radar-on': 'Pokéradar',
  'radar-off': 'Sem Pokéradar',
  'radio-hoenn': 'Rádio Hoenn',
  'radio-sinnoh': 'Rádio Sinnoh',
  'radio-off': 'Rádio desligado',
  'season-spring': 'Primavera',
  'season-summer': 'Verão',
  'season-autumn': 'Outono',
  'season-winter': 'Inverno',
};

String _oneCondition(String c) {
  final known = _conditions[c];
  if (known != null) return known;
  if (c == 'slot2-none') return 'Slot 2 vazio';
  if (c.startsWith('slot2-')) {
    return 'Slot 2: ${c.substring(6).pretty}';
  }
  if (c.startsWith('starter-')) {
    return 'Inicial: ${c.substring(8).pretty}';
  }
  return c.pretty;
}

/// "time-day+swarm-no" -> "Dia + Sem enxame"
String conditionLabel(String key) =>
    key.split('+').map(_oneCondition).join(' + ');

const _conditionTypes = {
  'time': 'Horário',
  'swarm': 'Enxame',
  'radar': 'Pokéradar',
  'slot2': 'Cartucho no slot GBA (Slot 2)',
  'radio': 'Rádio',
  'season': 'Estação',
  'starter': 'Inicial escolhido',
  'tv-option': 'Opção de TV',
  'story-progress': 'Progresso da história',
};

/// Nome de um tipo de condição ("time" -> "Horário").
String conditionTypeLabel(String name) => _conditionTypes[name] ?? name.pretty;

const _methodDescriptions = {
  'walk':
      'Encontros aleatórios ao andar em grama alta, cavernas e outras áreas de encontro.',
  'old-rod': 'Pesca com a Old Rod, a vara mais simples.',
  'good-rod': 'Pesca com a Good Rod, a vara intermediária.',
  'super-rod': 'Pesca com a Super Rod, a melhor vara.',
  'surf': 'Encontros ao navegar na água com Surf.',
  'rock-smash': 'Encontros ao quebrar pedras com Rock Smash.',
  'headbutt': 'Encontros ao usar Headbutt em árvores.',
  'headbutt-low': 'Encontros ao usar Headbutt em árvores (chance baixa).',
  'headbutt-normal': 'Encontros ao usar Headbutt em árvores (chance normal).',
  'headbutt-high': 'Encontros ao usar Headbutt em árvores (chance alta).',
  'dark-grass':
      'Grama escura (5ª geração), onde podem ocorrer encontros diferentes e em dupla.',
  'gift': 'Pokémon recebido de presente, sem batalha.',
  'gift-egg': 'Ovo recebido de presente.',
  'only-one':
      'Pokémon único no jogo, em geral estático (como lendários e o Snorlax).',
  'pokeflute': 'Pokémon que aparece ao usar a Poké Flauta.',
  'sos-encounter':
      'Pokémon que aparece ao ser chamado por outro durante uma batalha.',
  'devon-scope': 'Pokémon invisível, revelado com o Devon Scope.',
  'squirt-bottle': 'Pokémon que aparece ao usar o Regador (Squirt Bottle).',
  'roaming-grass': 'Pokémon errante, que muda de rota; encontrado em grama.',
  'roaming-water': 'Pokémon errante, que muda de rota; encontrado na água.',
};

/// Descrição curta em português, quando conhecida.
String? methodDescription(String m) => _methodDescriptions[m];

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