import 'package:flutter/material.dart';

import 'contest_effect_list_screen.dart';
import 'contest_type_list_screen.dart';

/// Grupo Contests: tipos de concurso e efeitos (normais e Super Contest).
class ContestsGroupScreen extends StatelessWidget {
  const ContestsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget item(IconData icon, String title, String subtitle, Widget screen) {
      return Column(
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(title),
            subtitle: Text(subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            ),
          ),
          const Divider(height: 1),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Contests')),
      body: ListView(
        children: [
          item(Icons.emoji_events, 'Tipos de concurso',
              'Cool, Beauty, Cute, Smart e Tough', const ContestTypeListScreen()),
          item(Icons.auto_awesome, 'Efeitos de concurso',
              'Efeitos dos golpes nos concursos',
              const ContestEffectListScreen(superContest: false)),
          item(Icons.star, 'Efeitos de Super Contest',
              'Efeitos dos golpes nos Super Contests',
              const ContestEffectListScreen(superContest: true)),
        ],
      ),
    );
  }
}