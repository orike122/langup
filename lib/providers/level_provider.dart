import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/level.dart';

const _kLevelKey = 'cefr_level';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final levelProvider = StateNotifierProvider<LevelNotifier, CefrLevel?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LevelNotifier(prefs);
});

class LevelNotifier extends StateNotifier<CefrLevel?> {
  final SharedPreferences _prefs;

  LevelNotifier(this._prefs)
      : super(CefrLevelExtension.fromString(_prefs.getString(_kLevelKey)));

  Future<void> setLevel(CefrLevel level) async {
    await _prefs.setString(_kLevelKey, level.storageKey);
    state = level;
  }

  Future<void> clearLevel() async {
    await _prefs.remove(_kLevelKey);
    state = null;
  }
}
