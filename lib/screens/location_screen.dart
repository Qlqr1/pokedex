import 'package:flutter/material.dart';

import '../repositories/location_repository.dart';
import '../utils/location_utils.dart';
import '../utils/string_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'location_area_screen.dart';

/// Áreas de uma localização.
class LocationScreen extends StatelessWidget {
  final String locationName;
  const LocationScreen({super.key, required this.locationName});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: locationName.pretty,
      emptyText: 'Esta localização não tem áreas registradas.',
      loader: () async =>
          (await LocationRepository.instance.getLocation(locationName)).areas,
      label: (r) => areaLabel(r.name, locationName),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LocationAreaScreen(
            areaName: r.name,
            title: areaLabel(r.name, locationName),
            locationTitle: locationName.pretty,
          ),
        ),
      ),
    );
  }
}