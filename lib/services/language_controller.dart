import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/ability_repository.dart';
import '../repositories/contest_repository.dart';
import '../repositories/dex_repository.dart';
import '../repositories/encounter_repository.dart';
import '../repositories/evolution_repository.dart';
import '../repositories/game_repository.dart';
import '../repositories/item_repository.dart';
import '../repositories/pokemon_extra_repository.dart';
import '../utils/lang.dart';

/// Guarda o idioma escolhido, avisa a interface e limpa os caches de textos
/// (eles guardam o texto já no idioma antigo).
class LanguageController extends ChangeNotifier {
  LanguageController._();
  static final instance = LanguageController._();

  static const _prefsKey = 'content_language';

  String get code => Lang.code;

  /// Chame na main(), antes do runApp.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null && saved.isNotEmpty) Lang.code = saved;
    } catch (_) {
      // sem armazenamento: usa o padrão (en)
    }
  }

  Future<void> setLanguage(String code) async {
    final next = code.toLowerCase();
    if (next == Lang.code) return;
    Lang.code = next;
    _clearTextCaches();
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, next);
    } catch (_) {}
  }

  void _clearTextCaches() {
    AbilityRepository.instance.clear();
    ItemRepository.instance.clear();
    DexRepository.instance.clear();
    ContestRepository.instance.clear();
    GameRepository.instance.clear();
    EncounterRepository.instance.clear();
    EvolutionRepository.instance.clear();
    PokemonExtraRepository.instance.clear();
  }
}
