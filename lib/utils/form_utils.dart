import 'string_utils.dart';

/// Nome curto de uma forma, para o seletor de formas.
/// Ex.: ("charizard-mega-x", "charizard") -> "Mega X"
///      ("raichu-alola", "raichu")        -> "Alola"
///      ("charizard-gmax", "charizard")   -> "Gigantamax"
String formLabel(
  String pokemonName,
  String speciesName, {
  required bool isDefault,
}) {
  if (isDefault) return 'Normal';

  final suffix = pokemonName.startsWith('$speciesName-')
      ? pokemonName.substring(speciesName.length + 1)
      : pokemonName;

  const labels = {
    'mega': 'Mega',
    'mega-x': 'Mega X',
    'mega-y': 'Mega Y',
    'primal': 'Primal',
    'gmax': 'Gigantamax',
    'eternamax': 'Eternamax',
    'alola': 'Alola',
    'galar': 'Galar',
    'hisui': 'Hisui',
    'paldea': 'Paldea',
  };
  return labels[suffix] ?? suffix.pretty;
}