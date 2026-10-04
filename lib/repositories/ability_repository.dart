import '../models/ability.dart';
import '../services/ability_service.dart';

class AbilityRepository {
  AbilityRepository._();
  static final instance = AbilityRepository._();

  final _service = AbilityService();
  List<NamedRef>? _list;
  final Map<String, Ability> _details = {};

  Future<List<NamedRef>> getList() async =>
      _list ??= await _service.fetchAbilityList();

  Future<Ability> getAbility(String idOrName) async {
    final cached = _details[idOrName];
    if (cached != null) return cached;
    final a = await _service.fetchAbility(idOrName);
    _details[idOrName] = a;
    _details[a.name] = a;
    return a;
  }
}