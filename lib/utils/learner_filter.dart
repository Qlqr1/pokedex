/// Decide quais formas aparecem nas listas "pokémons que têm esta habilidade /
/// aprendem este golpe".
///
/// Escondidas: Gigantamax e formas especiais/cosméticas (bonés e roupas do
/// Pikachu, totens, starters). Mantidas: padrão, regionais (-alola, -galar,
/// -hisui, -paldea) e Megas, que podem ser bem diferentes da forma base.
final RegExp _hiddenForms = RegExp(
  r'(-gmax$)'
  r'|(-cap$)'
  r'|(-totem)'
  r'|(^pikachu-(cosplay|rock-star|belle|pop-star|phd|libre|starter)$)'
  r'|(^eevee-starter$)',
);

bool showInLearnerList(String pokemonName) => !_hiddenForms.hasMatch(pokemonName);