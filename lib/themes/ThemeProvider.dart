// ignore_for_file: file_names, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadThemeFromPreferences();
  }

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme(bool isDarkMode) {
    _isDarkMode = isDarkMode;
    _saveThemeToPreferences(isDarkMode);
    notifyListeners();
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

  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[600],
    colorScheme: ColorScheme.light(
      primary: Colors.blue[600]!,
      secondary: Colors.orange[700]!,
      surface: Colors.white,
      error: Colors.red[700]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.grey[900]!,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[600],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey[900]),
      bodyMedium: TextStyle(color: Colors.grey[800]),
      titleLarge: TextStyle(color: Colors.grey[900], fontWeight: FontWeight.bold),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue[600],
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.orange[700],
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[200],
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue[800],
    colorScheme: ColorScheme.dark(
      primary: Colors.blue[800]!,
      secondary: Colors.orange[700]!,
      surface: Colors.grey[800]!,
      error: Colors.red[400]!,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.grey[100]!,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.grey[100]),
      bodyMedium: TextStyle(color: Colors.grey[200]),
      titleLarge: TextStyle(color: Colors.grey[100], fontWeight: FontWeight.bold),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue[800],
      textTheme: ButtonTextTheme.primary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.orange[700],
      foregroundColor: Colors.white,
    ),
    cardTheme: CardThemeData(
      color: Colors.grey[800],
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[700],
    ),
  );
}
