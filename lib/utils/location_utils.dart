import 'string_utils.dart';

/// Nome de uma área sem repetir o nome da localização.
/// "mt-coronet-1f-route-207" em "mt-coronet" -> "1f Route 207".
String areaLabel(String areaName, String locationName) {
  var s = areaName;
  if (s.startsWith('$locationName-')) s = s.substring(locationName.length + 1);
  if (s == areaName && s == locationName) return 'Área principal';
  if (s == 'area') return 'Área principal';
  return s.pretty;
}