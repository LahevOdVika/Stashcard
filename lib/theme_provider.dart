import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  Color _seedColor = Colors.green;
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