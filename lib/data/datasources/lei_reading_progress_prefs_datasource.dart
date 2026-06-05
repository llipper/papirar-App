import 'package:shared_preferences/shared_preferences.dart';

class LeiReadingProgressPrefsDatasource {
  static const _prefix = 'lei_reading_offset_';

  Future<double?> obterOffset(String leiKey) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('$_prefix$leiKey')) return null;
    return prefs.getDouble('$_prefix$leiKey');
  }

  Future<void> salvarOffset(String leiKey, double offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('$_prefix$leiKey', offset);
  }
}