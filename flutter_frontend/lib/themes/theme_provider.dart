import 'package:flutter/material.dart';
import 'package:flutter_frontend/themes/themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme = lightTheme;

  ThemeData get getTheme => _selectedTheme;

  void setTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  void toggleTheme() {
    if (_selectedTheme == lightTheme) {
      _selectedTheme = darkTheme;
    } else {
      _selectedTheme = lightTheme;
    }
    notifyListeners();
  }
}

