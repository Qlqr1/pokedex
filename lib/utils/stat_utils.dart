import 'string_utils.dart';

const _stats = {
  'hp': 'HP',
  'attack': 'Ataque',
  'defense': 'Defesa',
  'special-attack': 'Atq. Esp.',
  'special-defense': 'Def. Esp.',
  'speed': 'Velocidade',
  'accuracy': 'Precisão',
  'evasion': 'Evasão',
};

String statLabel(String name) => _stats[name] ?? name.pretty;

const _pokeathlon = {
  'speed': 'Velocidade',
  'power': 'Potência',
  'skill': 'Técnica',
  'stamina': 'Resistência',
  'jump': 'Salto',
};

String pokeathlonLabel(String name) => _pokeathlon[name] ?? name.pretty;

const _styles = {
  'attack': 'Ataque',
  'defense': 'Defesa',
  'support': 'Apoio',
};

String battleStyleLabel(String name) => _styles[name] ?? name.pretty;

/// "+2" / "-1" / "0"
String signed(int n) => n > 0 ? '+$n' : '$n';