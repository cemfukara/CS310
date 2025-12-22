import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService();

  bool _isDark = false;
  bool get isDark => _isDark;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    _isDark = await _prefs.isDarkMode();
    notifyListeners();
  }

  void toggleTheme() {
    _isDark = !_isDark;
    _prefs.setDarkMode(_isDark);
    notifyListeners();
  }
}
