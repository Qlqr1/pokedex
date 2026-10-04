import 'package:flutter/material.dart';

import '../repositories/location_repository.dart';
import '../utils/string_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'location_screen.dart';

/// Localizações de uma região.
class RegionScreen extends StatelessWidget {
  final String regionName;
  const RegionScreen({super.key, required this.regionName});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: regionName.pretty,
      searchable: true,
      searchHint: 'Buscar localização',
      emptyText: 'Nenhuma localização encontrada.',
      loader: () async =>
          (await LocationRepository.instance.getRegion(regionName)).locations,
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LocationScreen(locationName: r.name)),
      ),
    );
  }
}