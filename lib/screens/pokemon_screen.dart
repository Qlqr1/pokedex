import 'package:flutter/material.dart';

import '../models/models.dart';
import '../repositories/pokemon_repository.dart';
import '../services/pokeapi_service.dart'; // PokeApiException
import '../utils/form_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/evolution_tree.dart';
import '../widgets/pokemon_moves_tab.dart';
import '../widgets/sprite_gallery.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_badge.dart';
import 'ability_screen.dart';
import '../models/location.dart';
import '../repositories/location_repository.dart';
import '../widgets/pokemon_encounters_view.dart';

/// Página específica de um Pokémon.
/// Recebe o [Pokemon] já carregado pela lista e busca o restante (espécie,
/// fraquezas e evoluções) em seções independentes: se uma falhar, as outras
/// continuam aparecendo.
class PokemonScreen extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonScreen({super.key, required this.pokemon});

  @override
  State<PokemonScreen> createState() => _PokemonScreenState();
}

class _PokemonScreenState extends State<PokemonScreen> {
  static const Map<String, String> _statLabels = {
    'hp': 'HP',
    'attack': 'Ataque',
    'defense': 'Defesa',
    'special-attack': 'Atq. Esp.',
    'special-defense': 'Def. Esp.',
    'speed': 'Velocidade',
  };

  final PokemonRepository _repository = PokemonRepository.shared;

  // Dados da espécie: iguais para todas as formas.
  late final Future<PokemonSpecies> _species;
  late final Future<EvolutionChain?> _evolution;

  // Dados da forma selecionada (tipos, status, habilidades, imagens...).
  late Pokemon _current;
  late Future<Map<String, double>> _defense;
  late Future<List<PokemonAreaEncounter>> _encounters;

  /// Nome da forma que está sendo carregada (null = nenhuma).
  String? _loadingForm;

  Pokemon get _p => _current;

  @override
  void initState() {
    super.initState();
    _current = widget.pokemon;
    _species = _repository.getPokemonSpecies(_current.species.name);
    _defense = _repository.getDefenseMultipliers(_current);
    _evolution = _repository.getEvolutionChainOf(_current);
    _encounters = LocationRepository.instance.getPokemonEncounters(_current.id);
  }

  Future<void> _openPokemon(int id) async {
    if (id == _p.species.id) return;
    try {
      final next = await _repository.getPokemon(id);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PokemonScreen(pokemon: next)),
      );
    } on PokeApiException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir este Pokémon.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(pinned: true, title: Text(_p.species.name.pretty)),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: _buildHeader(context),
                  ),
                  _buildFormSelector(),
                ],
              ),
            ),
            const SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: 'Sobre'),
                    Tab(text: 'Status'),
                    Tab(text: 'Evolução'),
                    Tab(text: 'Onde Achar'),
                    Tab(text: 'Golpes'),
                    Tab(text: 'Galeria'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              _buildAboutTab(),
              _buildStatsTab(),
              _buildEvolutionTab(),
              _buildEncountersTab(),
              _buildMovesTab(),
              _buildGalleryTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Subseções (abas)
  // ---------------------------------------------------------------------------

  Widget _buildAboutTab() {
    return ListView(
      key: const PageStorageKey('tab-sobre'),
      padding: const EdgeInsets.all(16),
      children: [
        _AsyncSection<PokemonSpecies>(
          future: _species,
          builder: _buildSpecies,
        ),
        const SizedBox(height: 16),
        _buildInfoRow(),
        _SectionTitle('Habilidades'),
        _buildAbilities(),
      ],
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      key: const PageStorageKey('tab-status'),
      padding: const EdgeInsets.all(16),
      children: [
        ..._buildStats(),
        _SectionTitle('Fraquezas e resistências'),
        _AsyncSection<Map<String, double>>(
          future: _defense,
          builder: _buildDefense,
        ),
      ],
    );
  }

  Widget _buildMovesTab() => PokemonMovesTab(moves: _p.moves);

  Widget _buildGalleryTab() {
    return ListView(
      key: const PageStorageKey('tab-galeria'),
      padding: const EdgeInsets.all(16),
      children: [SpriteGallery(sprites: _p.sprites)],
    );
  }

  Widget _buildEvolutionTab() {
    return ListView(
      key: const PageStorageKey('tab-evolucao'),
      padding: const EdgeInsets.all(16),
      children: [
        _AsyncSection<EvolutionChain?>(
          future: _evolution,
          builder: (chain) {
            if (chain == null || chain.chain.evolvesTo.isEmpty) {
              return const Text('Este Pokémon não evolui.');
            }
            return EvolutionTree(
              root: chain.chain,
              currentSpecies: _p.species.name,
              onSelect: _openPokemon,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEncountersTab() {
    return ListView(
      key: const PageStorageKey('tab-onde-achar'),
      padding: const EdgeInsets.all(16),
      children: [
        _AsyncSection<List<PokemonAreaEncounter>>(
          future: _encounters,
          builder: (list) => PokemonEncountersView(encounters: list),
        ),
      ],
    );
  }

  /// Troca a forma exibida (Mega, Gigantamax, regionais...). A forma vem do
  /// repository (com cache), então voltar para uma forma já vista é instantâneo.
  Future<void> _selectForm(String pokemonName) async {
    if (pokemonName == _p.name || _loadingForm != null) return;
    setState(() => _loadingForm = pokemonName);
    try {
      final next = await _repository.getPokemon(pokemonName);
      if (!mounted) return;
      setState(() {
        _current = next;
        _defense = _repository.getDefenseMultipliers(next);
        _encounters = LocationRepository.instance.getPokemonEncounters(next.id);
        _loadingForm = null;
      });
    } on PokeApiException {
      if (!mounted) return;
      setState(() => _loadingForm = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível carregar esta forma.')),
      );
    }
  }

  /// Linha de formas. Só aparece se a espécie tiver mais de uma.
  Widget _buildFormSelector() {
    return FutureBuilder<PokemonSpecies>(
      future: _species,
      builder: (context, snapshot) {
        final species = snapshot.data;
        final varieties = species?.varieties ?? const <SpeciesVariety>[];
        if (species == null || varieties.length <= 1) {
          return const SizedBox.shrink();
        }
        return SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: varieties.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final v = varieties[index];
              final isLoading = _loadingForm == v.pokemon.name;
              return Center(
                child: ChoiceChip(
                  avatar: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                  label: Text(formLabel(
                    v.pokemon.name,
                    species.name,
                    isDefault: v.isDefault,
                  )),
                  selected: v.pokemon.name == _p.name,
                  onSelected: _loadingForm == null
                      ? (_) => _selectForm(v.pokemon.name)
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final image = _p.sprites.officialArtwork ?? _p.sprites.frontDefault;
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: image == null
              ? const Icon(Icons.catching_pokemon, size: 96)
              : Image.network(
                  image,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.catching_pokemon, size: 96),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          '#${_p.id.toString().padLeft(4, '0')}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        Text(
          _p.name.pretty,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: _p.typeNames.map((t) => TypeBadge(type: t)).toList(),
        ),
      ],
    );
  }

  Widget _buildInfoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _InfoTile(label: 'Altura', value: '${_p.heightInMeters} m'),
        _InfoTile(label: 'Peso', value: '${_p.weightInKg} kg'),
        _InfoTile(label: 'Exp. base', value: '${_p.baseExperience ?? '—'}'),
      ],
    );
  }

  Widget _buildSpecies(PokemonSpecies s) {
    // A PokéAPI não tem textos em português; usamos o inglês.
    final genus = s.genusIn('en');
    final flavor = s.flavorTextIn('en');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (genus != null)
          Text(genus, style: const TextStyle(fontStyle: FontStyle.italic)),
        if (s.isLegendary || s.isMythical || s.isBaby)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              spacing: 6,
              children: [
                if (s.isLegendary) const Chip(label: Text('Lendário')),
                if (s.isMythical) const Chip(label: Text('Mítico')),
                if (s.isBaby) const Chip(label: Text('Bebê')),
              ],
            ),
          ),
        if (flavor != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(flavor),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Taxa de captura: ${s.captureRate ?? '—'}   '
            'Felicidade inicial: ${s.baseHappiness ?? '—'}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildStats() {
    final total = _p.stats.fold<int>(0, (sum, s) => sum + s.baseStat);
    return [
      ..._p.stats.map((s) => StatBar(
            label: _statLabels[s.stat.name] ?? s.stat.name.pretty,
            value: s.baseStat,
          )),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text('Total: $total',
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    ];
  }

  Widget _buildAbilities() {
    final abilities = List.of(_p.abilities)
      ..sort((a, b) => a.slot.compareTo(b.slot));
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: abilities
          .map((a) => ActionChip(
                avatar: a.isHidden
                    ? const Icon(Icons.visibility_off, size: 16)
                    : null,
                label: Text(
                  a.isHidden
                      ? '${a.ability.name.pretty} (oculta)'
                      : a.ability.name.pretty,
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AbilityScreen(idOrName: a.ability.name),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildDefense(Map<String, double> multipliers) {
    List<MapEntry<String, double>> pick(bool Function(double) test) =>
        multipliers.entries.where((e) => test(e.value)).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    final groups = <(String, List<MapEntry<String, double>>)>[
      ('Fraco contra', pick((v) => v > 1)),
      ('Resistente a', pick((v) => v > 0 && v < 1)),
      ('Imune a', pick((v) => v == 0)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (title, entries) in groups)
          if (entries.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 4),
              child: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: entries
                  .map((e) => TypeBadge(type: e.key, suffix: _multiplier(e.value)))
                  .toList(),
            ),
          ],
      ],
    );
  }

  String _multiplier(double v) {
    if (v == 4) return '×4';
    if (v == 2) return '×2';
    if (v == 0.5) return '×½';
    if (v == 0.25) return '×¼';
    return '×$v';
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}

/// Carrega uma seção com indicador de progresso e mensagem de erro própria.
class _AsyncSection<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;

  const _AsyncSection({required this.future, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(
            'Não foi possível carregar esta seção.',
            style: TextStyle(color: Colors.grey.shade600),
          );
        }
        return builder(snapshot.data as T);
      },
    );
  }
}

/// Mantém a barra de abas fixa no topo enquanto o conteúdo rola.
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      tabBar != oldDelegate.tabBar;
}