import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _colorThemeKey = 'app_color_theme';
  static const _actionOrderKey = 'calendar_action_order';
  static const _summarySettingsKey = 'statistics_summary_settings';
  static SharedPreferences? _preferences;
  static final Map<String, Object> _fallback = {};

  static Future<void> initialize() async {
    try {
      _preferences = await SharedPreferences.getInstance();
    } on MissingPluginException {
      _preferences = null;
    }
  }

  static bool get isGuest =>
      _preferences?.getBool('local_guest') ??
      (_fallback['local_guest'] as bool? ?? false);

  static Future<void> setGuest(bool value) async {
    _fallback['local_guest'] = value;
    await _preferences?.setBool('local_guest', value);
  }

  static Map<String, dynamic>? getEntry(String date) {
    final key = 'local_entry_$date';
    final value = _preferences?.getString(key) ?? _fallback[key] as String?;
    if (value == null) return null;
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  }

  static Future<void> saveEntry(String date, Map<String, dynamic> entry) async {
    final key = 'local_entry_$date';
    final value = jsonEncode(entry);
    _fallback[key] = value;
    await _preferences?.setString(key, value);
  }

  static List<String> get actionOrder {
    final value =
        _preferences?.getStringList(_actionOrderKey) ??
        (_fallback[_actionOrderKey] as List<String>?);
    return value == null ? [] : List<String>.from(value);
  }

  static Future<void> saveActionOrder(List<String> order) async {
    _fallback[_actionOrderKey] = List<String>.from(order);
    await _preferences?.setStringList(_actionOrderKey, order);
  }

  static Map<String, dynamic> get summarySettings {
    final value =
        _preferences?.getString(_summarySettingsKey) ??
        _fallback[_summarySettingsKey] as String?;
    if (value == null) return {};
    return Map<String, dynamic>.from(jsonDecode(value) as Map);
  }

  static Future<void> saveSummarySettings(
    Map<String, dynamic> settings,
  ) async {
    final value = jsonEncode(settings);
    _fallback[_summarySettingsKey] = value;
    await _preferences?.setString(_summarySettingsKey, value);
  }

  static int get colorTheme => _preferences?.getInt(_colorThemeKey) ?? 0;

  static Future<void> saveColorTheme(int index) async {
    await _preferences?.setInt(_colorThemeKey, index);
  }

  static Iterable<Map<String, dynamic>> get entries sync* {
    final keys =
        _preferences?.getKeys() ??
        _fallback.keys.where((key) => key.startsWith('local_entry_')).toSet();
    for (final key in keys.where((key) => key.startsWith('local_entry_'))) {
      final value = _preferences?.getString(key) ?? _fallback[key] as String?;
      if (value != null) {
        yield Map<String, dynamic>.from(jsonDecode(value) as Map);
      }
    }
  }
}
