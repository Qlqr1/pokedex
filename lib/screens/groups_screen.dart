import 'package:flutter/material.dart';

import '../services/language_controller.dart';
import '../theme/app_theme.dart';
import '../utils/lang.dart';
import '../widgets/language_picker.dart';
import 'berry_list_screen.dart';
import 'contests_group_screen.dart';
import 'currency_list_screen.dart';
import 'encounters_group_screen.dart';
import 'evolution_group_screen.dart';
import 'generation_list_screen.dart';
import 'global_search_screen.dart';
import 'item_list_screen.dart';
import 'locations_group_screen.dart';
import 'machine_list_screen.dart';
import 'move_list_screen.dart';
import 'pokemon_group_screen.dart';

class _ApiGroup {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color tint; // cor de fundo da caixa do ícone
  final WidgetBuilder builder;

  const _ApiGroup(this.title, this.icon, this.tint, this.builder,
      {this.subtitle});
}

// Não é const porque os builders são funções.
final _featured = _ApiGroup(
  'Pokémon',
  Icons.catching_pokemon,
  Colors.white24,
  (_) => const PokemonGroupScreen(),
  subtitle: 'Explore todas as espécies',
);

final _groups = <_ApiGroup>[
  _ApiGroup('Berries', Icons.eco, const Color(0xFF3A2230),
      (_) => const BerryListScreen()),
  _ApiGroup('Concursos', Icons.emoji_events, const Color(0xFF3A3322),
      (_) => const ContestsGroupScreen()),
  _ApiGroup('Moedas', Icons.attach_money, const Color(0xFF3A3A22),
      (_) => const CurrencyListScreen()),
  _ApiGroup('Encontros', Icons.explore, const Color(0xFF22343A),
      (_) => const EncountersGroupScreen()),
  _ApiGroup('Evolução', Icons.trending_up, const Color(0xFF2B2A3D),
      (_) => const EvolutionGroupScreen()),
  _ApiGroup('Jogos', Icons.sports_esports, const Color(0xFF2D3A22),
      (_) => const GenerationListScreen()),
  _ApiGroup('Itens', Icons.backpack, const Color(0xFF3A2A22),
      (_) => const ItemListScreen()),
  _ApiGroup('Locais', Icons.map, const Color(0xFF22393A),
      (_) => const LocationsGroupScreen()),
  _ApiGroup('Máquinas', Icons.album, const Color(0xFF2A2F3A),
      (_) => const MachineListScreen()),
  _ApiGroup('Golpes', Icons.flash_on, const Color(0xFF3A2236),
      (_) => const MoveListScreen()),
];

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  void _open(BuildContext context, WidgetBuilder builder) =>
      Navigator.push(context, MaterialPageRoute(builder: builder));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _Header(
            onSearch: () => _open(context, (_) => const GlobalSearchScreen()),
            onLanguage: () => showLanguagePicker(context),
          )),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverToBoxAdapter(
              child: _FeaturedTile(
                group: _featured,
                onTap: () => _open(context, _featured.builder),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.35,
              ),
              itemCount: _groups.length,
              itemBuilder: (context, i) => _GroupTile(
                group: _groups[i],
                onTap: () => _open(context, _groups[i].builder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho vermelho com o título e a busca global.
class _Header extends StatelessWidget {
  final VoidCallback onSearch;
  final VoidCallback onLanguage;
  const _Header({required this.onSearch, required this.onLanguage});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color.fromRGBO(255, 255, 255, .12), width: 14),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Pokédex',
                            style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                      // Idioma do conteúdo (endpoint /language)
                      ListenableBuilder(
                        listenable: LanguageController.instance,
                        builder: (context, _) => InkWell(
                          borderRadius: BorderRadius.circular(99),
                          onTap: onLanguage,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 0, 0, .25),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.translate,
                                    size: 16, color: Colors.white),
                                const SizedBox(width: 6),
                                Text(
                                  Lang.code.toUpperCase(),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, .25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search,
                              size: 18, color: Color(0xFFFFD9D9)),
                          SizedBox(width: 8),
                          Text('Buscar pokémon, itens, golpes…',
                              style: TextStyle(
                                  color: Color(0xFFFFD9D9), fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedTile extends StatelessWidget {
  final _ApiGroup group;
  final VoidCallback onTap;
  const _FeaturedTile({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.red, AppColors.redDark],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, .2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(group.icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.title,
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      if (group.subtitle != null)
                        Text(group.subtitle!,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFFFFE3E3))),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  final _ApiGroup group;
  final VoidCallback onTap;
  const _GroupTile({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: group.tint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(group.icon, size: 20, color: Colors.white70),
                ),
                Text(group.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
