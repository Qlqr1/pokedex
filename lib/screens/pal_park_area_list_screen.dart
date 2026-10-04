import 'package:flutter/material.dart';

import '../repositories/location_repository.dart';
import '../widgets/named_ref_list_screen.dart';
import 'pal_park_area_screen.dart';

class PalParkAreaListScreen extends StatelessWidget {
  const PalParkAreaListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Pal Park',
      loader: LocationRepository.instance.getPalParkAreas,
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PalParkAreaScreen(areaName: r.name)),
      ),
    );
  }
}