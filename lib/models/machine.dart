/// Em um jogo (grupo de versões), esta TM/HM ensina [move].
class MachineEntry {
  final String versionGroup;
  final String move;
  const MachineEntry({required this.versionGroup, required this.move});
}

/// Uma TM/HM/TR (item "tm01", "hm01"...) e o golpe que ensina em cada jogo.
class MachineInfo {
  final String name;
  final String? spriteUrl;
  final List<MachineEntry> entries;
  const MachineInfo(
      {required this.name, required this.spriteUrl, required this.entries});
}