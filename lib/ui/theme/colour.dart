import 'package:flutter/material.dart';

class AnitempThemeColourHandler {
  final BuildContext _context;

  AnitempThemeColourHandler(this._context);

  Color _resolveColourByBrightness(Color light, Color dark) =>
      Theme.of(_context).brightness == Brightness.light ? light : dark;

  Color get success =>
      _resolveColourByBrightness(Colors.green[400]!, Colors.green[700]!);

  Color get error =>
      _resolveColourByBrightness(Colors.redAccent, Colors.red[700]!);

  MaterialStateProperty<Color> get mspSuccess =>
      MaterialStateProperty.all(success);

  MaterialStateProperty<Color> get mspError => MaterialStateProperty.all(error);
}
