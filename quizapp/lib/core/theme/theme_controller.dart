import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeController extends ChangeNotifier {
  int _themeIndex = 0;

  int get themeIndex => _themeIndex;
  AppPalette get palette => AppPalettes.all[_themeIndex];

  void setTheme(int index) {
    if (index < 0 || index >= AppPalettes.all.length) return;
    _themeIndex = index;
    notifyListeners();
  }

  void nextTheme() {
    _themeIndex = (_themeIndex + 1) % AppPalettes.all.length;
    notifyListeners();
  }

  String get currentThemeName {
    switch (_themeIndex) {
      case 0:
        return 'Violet';
      case 1:
        return 'Pink';
      case 2:
        return 'Mint';
      default:
        return 'Theme';
    }
  }
}