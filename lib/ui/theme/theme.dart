import 'package:flutter/material.dart';

class AnitempThemeDataGetter {
  final Locale _locale;

  AnitempThemeDataGetter(this._locale);

  /// Condition of font:
  ///
  /// * Chinese
  ///   * Is traditional?
  ///     * Yes: Set language as Chinese (Hong Kong) or Chinese (Macau)?
  ///       * Yes => `Noto Sans HK`
  ///       * No => `Noto Sans TC`
  ///   * No => `Noto Sans SC`
  /// * Japanese => `Noto Sans JP`
  /// * Korean => `Noto Sans KR`
  /// * Non-CJK language => `Roboto`
  String get _fontName {
    String noto = "Noto Sans";
    switch (_locale.languageCode) {
      case "zh":
        if (_locale.scriptCode == "Hant") {
          // If using Trad. Chinese
          if (<String>["HK", "MO"].contains(_locale.scriptCode)) {
            // Either set language as Chinese (Hong Kong/Macau)
            return "$noto HK";
          }
          return "$noto TC";
        }
        return "$noto SC";
      case "ko":
        return "$noto KR";
      case "jp":
        return "$noto JP";
      default:
        return "Roboto";
    }
  }

  ThemeData get light =>
      ThemeData(brightness: Brightness.light, fontFamily: _fontName);

  ThemeData get dark =>
      ThemeData(brightness: Brightness.dark, fontFamily: _fontName);
}
