enum CefrLevel { a1, a2, b1, b2, c1, c2 }

extension CefrLevelExtension on CefrLevel {
  String get displayName => name.toUpperCase();

  String get storageKey => name;

  static CefrLevel? fromString(String? s) {
    if (s == null) return null;
    try {
      return CefrLevel.values.firstWhere((e) => e.name == s);
    } catch (_) {
      return null;
    }
  }
}
