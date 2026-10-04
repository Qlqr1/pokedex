import '../models/machine.dart';
import '../models/named_ref.dart';
import '../services/machine_service.dart';

/// Cache em memória; falhas não ficam guardadas ("Tentar novamente" funciona).
class MachineRepository {
  MachineRepository._();
  static final instance = MachineRepository._();

  final _service = MachineService();
  Future<List<NamedRef>>? _list;
  final Map<String, Future<MachineInfo>> _machines = {};

  Future<List<NamedRef>> getList() {
    final f = _list ??= _service.fetchMachineItems();
    f.then((_) {}, onError: (_) {
      _list = null;
    });
    return f;
  }

  Future<MachineInfo> getMachine(String itemName) {
    final f =
        _machines.putIfAbsent(itemName, () => _service.fetchMachine(itemName));
    f.then((_) {}, onError: (_) {
      _machines.remove(itemName);
    });
    return f;
  }
}