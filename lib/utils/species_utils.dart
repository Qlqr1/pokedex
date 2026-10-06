import 'string_utils.dart';

const _eggGroups = {
  'monster': 'Monstro',
  'water1': 'Água 1',
  'water2': 'Água 2',
  'water3': 'Água 3',
  'bug': 'Inseto',
  'flying': 'Voador',
  'ground': 'Campo',
  'fairy': 'Fada',
  'plant': 'Planta',
  'humanshape': 'Humanoide',
  'mineral': 'Mineral',
  'indeterminate': 'Amorfo',
  'ditto': 'Ditto',
  'dragon': 'Dragão',
  'no-eggs': 'Desconhecido',
};

String eggGroupLabel(String name) => _eggGroups[name] ?? name.pretty;

const _growthLabels = {
  'slow': 'Lenta',
  'medium-slow': 'Média lenta',
  'medium': 'Média rápida',
  'fast': 'Rápida',
  'slow-then-very-fast': 'Errática',
  'fast-then-very-slow': 'Flutuante',
};

/// Experiência total necessária para chegar ao nível 100.
const _growthExp = {
  'slow': 1250000,
  'medium-slow': 1059860,
  'medium': 1000000,
  'fast': 800000,
  'slow-then-very-fast': 600000,
  'fast-then-very-slow': 1640000,
};

String growthRateLabel(String name) => _growthLabels[name] ?? name.pretty;
int? growthRateExpAt100(String name) => _growthExp[name];

const _habitats = {
  'cave': 'Caverna',
  'forest': 'Floresta',
  'grassland': 'Campo',
  'mountain': 'Montanha',
  'rare': 'Raro',
  'rough-terrain': 'Terreno acidentado',
  'sea': 'Mar',
  'urban': 'Urbano',
  'waters-edge': 'Beira d\'água',
};

String habitatLabel(String name) => _habitats[name] ?? name.pretty;

/// 1250000 -> "1.250.000"
String thousands(int n) {
  final s = n.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

/// 12.5 -> "12,5%"; 50 -> "50%"
String percent(double v) {
  final s = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  return '${s.replaceAll('.', ',')}%';
}