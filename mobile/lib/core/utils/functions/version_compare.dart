int _part(String v) => int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

/// Returns true when [current] is strictly below [minimum] (semver-ish).
bool isVersionBelow(String current, String minimum) {
  final a = current.split('.');
  final b = minimum.split('.');
  final len = a.length > b.length ? a.length : b.length;
  for (var i = 0; i < len; i++) {
    final ai = i < a.length ? _part(a[i]) : 0;
    final bi = i < b.length ? _part(b[i]) : 0;
    if (ai < bi) return true;
    if (ai > bi) return false;
  }
  return false;
}
