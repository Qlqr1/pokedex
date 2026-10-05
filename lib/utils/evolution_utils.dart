import 'string_utils.dart';

const _triggers = {
  'level-up': 'Subir de nível',
  'trade': 'Troca',
  'use-item': 'Usar item',
  'shed': 'Shed',
  'spin': 'Girar',
  'tower-of-two-fists': 'Torre dos Dois Punhos',
  'three-critical-hits': 'Três acertos críticos',
  'take-damage': 'Sofrer dano',
  'other': 'Outros',
  'agile-style-move': 'Golpe em estilo ágil',
  'strong-style-move': 'Golpe em estilo forte',
  'recoil-damage': 'Dano de recuo',
};

String triggerLabel(String name) => _triggers[name] ?? name.pretty;

const _triggerDescriptions = {
  'level-up': 'A evolução acontece ao subir de nível, quando as outras '
      'condições (nível, amizade, horário etc.) são atendidas.',
  'trade': 'A evolução acontece quando o Pokémon é trocado com outro '
      'treinador, às vezes segurando um item ou com uma espécie específica.',
  'use-item': 'A evolução acontece ao usar um item no Pokémon, como uma '
      'pedra evolutiva.',
  'shed': 'Evolução especial do Nincada: ao evoluir, o Shedinja aparece '
      'se houver espaço na equipe e uma Poké Ball.',
  'spin': 'A evolução acontece ao girar o personagem após dar um doce ao '
      'Pokémon.',
  'tower-of-two-fists': 'A evolução acontece na Torre dos Dois Punhos, '
      'usando um item específico.',
  'three-critical-hits': 'A evolução acontece após acertar três golpes '
      'críticos em uma mesma batalha.',
  'take-damage': 'A evolução acontece após sofrer uma quantidade de dano '
      'e depois passar por um local específico.',
  'other': 'Evoluções com condições que não se encaixam nos outros gatilhos.',
  'agile-style-move': 'A evolução acontece ao usar um golpe em estilo ágil '
      'um número de vezes.',
  'strong-style-move': 'A evolução acontece ao usar um golpe em estilo forte '
      'um número de vezes.',
  'recoil-damage': 'A evolução acontece após acumular dano de recuo.',
};

String? triggerDescription(String name) => _triggerDescriptions[name];