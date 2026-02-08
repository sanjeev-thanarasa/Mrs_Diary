import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  static const String _languageKey = 'app_language_code';

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('ta');
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString(_themeKey);
    final languageCode = prefs.getString(_languageKey);

    if (themeValue != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeValue,
        orElse: () => ThemeMode.light,
      );
    }

    if (languageCode != null && languageCode.isNotEmpty) {
      _locale = Locale(languageCode);
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setLanguageCode(String code) async {
    _locale = Locale(code);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }
}
