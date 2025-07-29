import 'package:flutter/material.dart';

/// Provides theme configuration for the application.
///
/// This provider manages the seed color and theme mode (light/dark/system)
/// and generates Material themes based on these settings.
class ThemeProvider with ChangeNotifier {
  /// Sets the seed color for theme generation and notifies listeners.
  Color _seedColor = Colors.green;

  ///Sets the theme mode and notifies listeners.
  ThemeMode _mode = ThemeMode.system;

  Color get seedColor => _seedColor;

  ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light
    ),
  );

  ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark
    ),
  );

  ThemeMode get themeMode => _mode;

  void setSeedColor(Color color) {
    _seedColor = color;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }
}