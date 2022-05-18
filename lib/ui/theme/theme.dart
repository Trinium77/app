import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnitempThemeData {
  static final TextTheme Function([TextTheme?]) _defaultFont =
      GoogleFonts.robotoTextTheme;

  static ThemeData light() => ThemeData.light()
      .copyWith(textTheme: _defaultFont(ThemeData.light().textTheme));

  static ThemeData dark() {
    return ThemeData.dark()
        .copyWith(textTheme: _defaultFont(ThemeData.dark().textTheme));
  }
}
