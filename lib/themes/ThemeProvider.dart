// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    _saveThemeToPreferences(isDarkMode);
    notifyListeners();  // ✅ Important: Updates the UI when the theme changes
  }

  Future<void> _saveThemeToPreferences(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> _loadThemeFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? storedIsDarkMode = prefs.getBool('isDarkMode');
    if (storedIsDarkMode != null) {
      _isDarkMode = storedIsDarkMode;
      notifyListeners();
    }
  }
}
