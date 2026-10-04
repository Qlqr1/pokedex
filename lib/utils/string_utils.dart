extension PrettyString on String {
  /// "special-attack" -> "Special Attack", "bulbasaur" -> "Bulbasaur"
  String get pretty => split('-')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0].toUpperCase() + w.substring(1))
      .join(' ');
}