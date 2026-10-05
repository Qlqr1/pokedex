/// Condições que podem aparecer nos detalhes de uma evolução.
/// A PokéAPI não tem endpoint para elas; são os campos de `evolution_details`
/// da cadeia de evolução, explicados aqui em português.
class EvolutionVariable {
  final String key; // nome do campo na API
  final String title;
  final String description;
  final String example;
  const EvolutionVariable({
    required this.key,
    required this.title,
    required this.description,
    required this.example,
  });
}

const evolutionVariables = <EvolutionVariable>[
  EvolutionVariable(
    key: 'trigger',
    title: 'Gatilho',
    description:
        'O que dispara a evolução: subir de nível, troca, usar um item etc. '
        'É sempre combinado com as outras condições.',
    example: 'Level-up, Troca, Usar item (veja a lista de Gatilhos).',
  ),
  EvolutionVariable(
    key: 'min_level',
    title: 'Nível mínimo',
    description: 'Nível que o Pokémon precisa ter alcançado.',
    example: 'Charmander evolui para Charmeleon no nível 16.',
  ),
  EvolutionVariable(
    key: 'item',
    title: 'Item usado',
    description: 'Item que precisa ser usado no Pokémon para evoluir.',
    example: 'Pikachu evolui para Raichu com a Thunder Stone.',
  ),
  EvolutionVariable(
    key: 'held_item',
    title: 'Item segurado',
    description:
        'Item que o Pokémon precisa estar segurando quando o gatilho acontece.',
    example: 'Gligar evolui para Gliscor com o Razor Fang, à noite.',
  ),
  EvolutionVariable(
    key: 'gender',
    title: 'Gênero',
    description: 'Gênero necessário para a evolução (1 = fêmea, 2 = macho).',
    example: 'Snorunt fêmea evolui para Froslass com a Dawn Stone.',
  ),
  EvolutionVariable(
    key: 'time_of_day',
    title: 'Horário',
    description: 'Período do dia em que a evolução precisa acontecer '
        '(dia, anoitecer ou noite).',
    example: 'Eevee evolui para Espeon de dia e para Umbreon à noite.',
  ),
  EvolutionVariable(
    key: 'location',
    title: 'Local',
    description:
        'Local em que o Pokémon precisa estar para que a evolução aconteça.',
    example: 'Magneton evolui para Magnezone em locais com campo magnético.',
  ),
  EvolutionVariable(
    key: 'known_move',
    title: 'Golpe conhecido',
    description: 'Golpe que o Pokémon precisa conhecer.',
    example: 'Piloswine evolui para Mamoswine conhecendo Ancient Power.',
  ),
  EvolutionVariable(
    key: 'known_move_type',
    title: 'Tipo de golpe conhecido',
    description: 'Tipo de golpe que o Pokémon precisa conhecer.',
    example: 'Eevee evolui para Sylveon conhecendo um golpe do tipo Fairy.',
  ),
  EvolutionVariable(
    key: 'min_happiness',
    title: 'Felicidade mínima',
    description: 'Nível de amizade (felicidade) mínimo com o treinador.',
    example: 'Pichu evolui para Pikachu com amizade alta.',
  ),
  EvolutionVariable(
    key: 'min_affection',
    title: 'Afeto mínimo',
    description:
        'Nível de afeto mínimo, obtido nas interações de Pokémon-Amie/Refresh.',
    example: 'Eevee evolui para Sylveon com afeto alto.',
  ),
  EvolutionVariable(
    key: 'min_beauty',
    title: 'Beleza mínima',
    description: 'Valor mínimo de beleza (atributo de concursos).',
    example: 'Feebas evolui para Milotic com beleza alta.',
  ),
  EvolutionVariable(
    key: 'needs_overworld_rain',
    title: 'Chuva no mundo',
    description: 'Precisa estar chovendo no mundo fora de batalha.',
    example: 'Sliggoo evolui para Goodra subindo de nível na chuva.',
  ),
  EvolutionVariable(
    key: 'party_species',
    title: 'Espécie na equipe',
    description: 'Outra espécie que precisa estar na equipe do treinador.',
    example: 'Mantyke evolui para Mantine com um Remoraid na equipe.',
  ),
  EvolutionVariable(
    key: 'party_type',
    title: 'Tipo na equipe',
    description: 'Tipo de Pokémon que precisa estar na equipe.',
    example: 'Pancham evolui para Pangoro com um Pokémon Dark na equipe.',
  ),
  EvolutionVariable(
    key: 'relative_physical_stats',
    title: 'Ataque x Defesa',
    description: 'Relação entre Ataque e Defesa: 1 = Ataque maior, '
        '-1 = Defesa maior, 0 = iguais.',
    example: 'Tyrogue evolui para Hitmonlee, Hitmonchan ou Hitmontop.',
  ),
  EvolutionVariable(
    key: 'trade_species',
    title: 'Espécie na troca',
    description: 'Espécie com a qual o Pokémon precisa ser trocado.',
    example: 'Karrablast e Shelmet evoluem quando trocados entre si.',
  ),
  EvolutionVariable(
    key: 'turn_upside_down',
    title: 'Virar o console',
    description:
        'O console precisa ser virado de cabeça para baixo durante a evolução.',
    example: 'Inkay evolui para Malamar ao subir de nível com o console de ponta-cabeça.',
  ),
];