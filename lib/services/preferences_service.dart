import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String themeKey = "isDarkMode";

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, value);
  }
}
