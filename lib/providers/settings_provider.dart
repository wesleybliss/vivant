import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DistanceUnit {
  metric,
  imperial;

  String get label => this == metric ? 'Metric (km)' : 'Imperial (mi)';
}

class SettingsProvider with ChangeNotifier {
  static const String _themeModeKey = 'settings_theme_mode';
  static const String _languageKey = 'settings_language';
  static const String _minRatingKey = 'settings_min_rating';
  static const String _distanceUnitKey = 'settings_distance_unit';

  ThemeMode _themeMode = ThemeMode.system;
  String _language = 'en';
  double _minRating = 0.0;
  DistanceUnit _distanceUnit = DistanceUnit.metric;

  ThemeMode get themeMode => _themeMode;
  String get language => _language;
  double get minRating => _minRating;
  DistanceUnit get distanceUnit => _distanceUnit;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    final themeIndex = prefs.getInt(_themeModeKey);
    if (themeIndex != null) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    // Load Language
    _language = prefs.getString(_languageKey) ?? 'en';

    // Load Min Rating
    _minRating = prefs.getDouble(_minRatingKey) ?? 0.0;

    // Load Distance Unit
    final distanceUnitIndex = prefs.getInt(_distanceUnitKey);
    if (distanceUnitIndex != null) {
      _distanceUnit = DistanceUnit.values[distanceUnitIndex];
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, lang);
  }

  Future<void> setMinRating(double rating) async {
    _minRating = rating;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_minRatingKey, rating);
  }

  Future<void> setDistanceUnit(DistanceUnit unit) async {
    _distanceUnit = unit;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_distanceUnitKey, unit.index);
  }
}
