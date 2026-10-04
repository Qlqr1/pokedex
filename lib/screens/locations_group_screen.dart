import 'package:flutter/material.dart';

import '../repositories/location_repository.dart';
import '../widgets/named_ref_list_screen.dart';
import 'pal_park_area_list_screen.dart';
import 'region_screen.dart';

/// Grupo Locations: regiões + Pal Park no final.
class LocationsGroupScreen extends StatelessWidget {
  const LocationsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Locations',
      loader: LocationRepository.instance.getRegions,
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RegionScreen(regionName: r.name)),
      ),
      footer: [
        ListTile(
          leading: const Icon(Icons.park),
          title: const Text('Pal Park'),
          subtitle: const Text('Áreas de transferência'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PalParkAreaListScreen()),
          ),
        ),
      ],
    );
  }
}