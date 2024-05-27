import 'package:flutter/material.dart';
import 'package:flutter_frontend/themes/themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme = lightTheme;

  ThemeData get getTheme => _selectedTheme;

  ThemeData get getLightTheme => lightTheme;

  ThemeData get getDarkTheme => darkTheme;

  void setTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  ThemeData getSystemTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return darkTheme;
    } else {
      return lightTheme;
    }
  }

  void setSystemTheme(Brightness brightness) {
    if (brightness == Brightness.dark) {
      _selectedTheme = darkTheme;
    } else {
      _selectedTheme = lightTheme;
    }
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

