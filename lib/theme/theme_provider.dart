import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // Load saved theme
  }

  void toggleTheme(String theme) async {
    if (theme == "Dark") {
      _themeMode = ThemeMode.dark;
    } else if (theme == "Light") {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners();
    _saveTheme(theme);
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString("theme") ?? "System";
    toggleTheme(theme);
  }

  Future<void> _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("theme", theme);
  }
}
