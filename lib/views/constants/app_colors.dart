import 'package:flutter/material.dart';
import '../../state/auth/backend/local_storage.dart';
import 'strings.dart';

@immutable
class AppColors {
  static final ValueNotifier<int> theme = ValueNotifier<int>(0);
  static final themes = <AppColorTheme>[
    AppColorTheme(Strings.purpleColorTheme, Color(0xFF2D0E79), Color(0xFF40218E), Color(0xFF41F755), Color(0xFFC49BF7)),
    AppColorTheme(Strings.blueColorTheme, Color(0xFF0D2B52), Color(0xFF164A7A), Color(0xFF64D8FF), Color(0xFFB8E7FF)),
    AppColorTheme(Strings.greenColorTheme, Color(0xFF123B2A), Color(0xFF1E6045), Color(0xFF7CFF9B), Color(0xFFB8F5C8)),
    AppColorTheme(Strings.burgundyColorTheme, Color(0xFF4A1328), Color(0xFF70203D), Color(0xFFFF9DBB), Color(0xFFFFC2D1)),
  ];
  static Color get buttonColor => themes[theme.value].button;
  static Color get primaryColor => themes[theme.value].primary;
  static Color textColor = Color(0xFFFFFFFF);
  static Color get accentColor => themes[theme.value].accent;
  static Color get hintColor => themes[theme.value].hint;
  static Color black = Color(0xFF000000);
  static Color red = Color(0xFFFF0000);
  static Color grey = Color(0xFF808080);

  const AppColors._();

  static Future<void> setTheme(int index) async {
    if (index < 0 || index >= themes.length) return;
    theme.value = index;
    await LocalStorage.saveColorTheme(index);
  }

  static Future<void> resetTheme() => setTheme(0);
}

class AppColorTheme {
  final String name;
  final Color primary;
  final Color accent;
  final Color button;
  final Color hint;
  const AppColorTheme(this.name, this.primary, this.accent, this.button, this.hint);
}