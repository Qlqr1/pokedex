import 'package:flutter/material.dart';

import '../repositories/machine_repository.dart';
import '../utils/machine_utils.dart';
import '../widgets/named_ref_list_screen.dart';
import 'machine_screen.dart';

/// Lista de TMs, HMs e TRs.
class MachineListScreen extends StatelessWidget {
  const MachineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NamedRefListScreen(
      title: 'Machines',
      searchable: true,
      searchHint: 'Buscar TM / HM / TR',
      searchById: false,
      emptyText: 'Nenhuma máquina encontrada.',
      loader: MachineRepository.instance.getList,
      label: (r) => machineLabel(r.name),
      leading: (_) => const Icon(Icons.album),
      onTap: (context, r) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MachineScreen(itemName: r.name)),
      ),
    );
  }
}