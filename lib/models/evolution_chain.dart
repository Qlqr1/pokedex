import 'evolution_detail.dart';
import 'named_api_resource.dart';

/// /evolution-chain/{id}
class EvolutionChain {
  final int id;
  final NamedApiResource? babyTriggerItem;
  final ChainLink chain;

  const EvolutionChain({
    required this.id,
    required this.babyTriggerItem,
    required this.chain,
  });

  factory EvolutionChain.fromJson(Map<String, dynamic> json) => EvolutionChain(
        id: json['id'] as int,
        babyTriggerItem: parseNamed(json['baby_trigger_item']),
        chain: ChainLink.fromJson(json['chain'] as Map<String, dynamic>),
      );
}

/// Nó da árvore evolutiva (recursivo: evolvesTo contém outros ChainLink).
class ChainLink {
  final bool isBaby;
  final NamedApiResource species;
  final List<EvolutionDetail> evolutionDetails;
  final List<ChainLink> evolvesTo;

  const ChainLink({
    required this.isBaby,
    required this.species,
    required this.evolutionDetails,
    required this.evolvesTo,
  });

  factory ChainLink.fromJson(Map<String, dynamic> json) => ChainLink(
        isBaby: json['is_baby'] as bool? ?? false,
        species:
            NamedApiResource.fromJson(json['species'] as Map<String, dynamic>),
        evolutionDetails:
            parseList(json['evolution_details'], EvolutionDetail.fromJson),
        evolvesTo: parseList(json['evolves_to'], ChainLink.fromJson),
      );
}
