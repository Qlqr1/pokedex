class BerryFlavor {
  final String name; // spicy, dry, sweet, bitter, sour
  final int potency;
  const BerryFlavor({required this.name, required this.potency});
}

class BerryDetail {
  final int id;
  final String name; // ex.: "cheri"
  final String itemName; // ex.: "cheri-berry" (abre a ItemScreen)
  final int growthTime; // horas por estágio de crescimento
  final int maxHarvest;
  final int naturalGiftPower;
  final String? naturalGiftType;
  final int size; // mm
  final int smoothness;
  final int soilDryness;
  final String? firmness;
  final List<BerryFlavor> flavors;

  const BerryDetail({
    required this.id,
    required this.name,
    required this.itemName,
    required this.growthTime,
    required this.maxHarvest,
    required this.naturalGiftPower,
    required this.naturalGiftType,
    required this.size,
    required this.smoothness,
    required this.soilDryness,
    required this.firmness,
    required this.flavors,
  });

  factory BerryDetail.fromJson(Map<String, dynamic> j) => BerryDetail(
        id: j['id'],
        name: j['name'],
        itemName: j['item']['name'],
        growthTime: j['growth_time'],
        maxHarvest: j['max_harvest'],
        naturalGiftPower: j['natural_gift_power'],
        naturalGiftType: j['natural_gift_type']?['name'],
        size: j['size'],
        smoothness: j['smoothness'],
        soilDryness: j['soil_dryness'],
        firmness: j['firmness']?['name'],
        flavors: (j['flavors'] as List)
            .map((e) => BerryFlavor(
                  name: e['flavor']['name'],
                  potency: e['potency'],
                ))
            .toList(),
      );
}