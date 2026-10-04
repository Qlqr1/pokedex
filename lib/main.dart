import 'package:flutter/material.dart';
import 'screens/groups_screen.dart';

void main() => runApp(const PokedexApp());

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pokédex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.red, useMaterial3: true),
        home: const GroupsScreen(),
      );
}