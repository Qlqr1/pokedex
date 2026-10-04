import 'string_utils.dart';

/// "cheri" -> "Cheri Berry" (a API lista as berries sem o sufixo).
String berryLabel(String name) => '${name.pretty} Berry';

/// Nome do item da berry (usado para a imagem e para a ItemScreen).
String berryItemName(String name) => '$name-berry';

const _flavors = {
  'spicy': 'Picante',
  'dry': 'Seco',
  'sweet': 'Doce',
  'bitter': 'Amargo',
  'sour': 'Azedo',
};

String flavorLabel(String name) => _flavors[name] ?? name.pretty;

const _firmness = {
  'very-soft': 'Muito macia',
  'soft': 'Macia',
  'hard': 'Dura',
  'very-hard': 'Muito dura',
  'super-hard': 'Super dura',
};

String firmnessLabel(String name) => _firmness[name] ?? name.pretty;