import 'package:fluent_ui/fluent_ui.dart' show ThemeMode;
import 'package:flutter/widgets.dart' show Locale;
import 'package:hive/hive.dart';

part 'locale.dart';
part 'theme_mode.dart';

final List<TypeAdapter> custom_adapters =
    List.unmodifiable([_LocaleTypeAdapter(), _ThemeModeTypeAdapter()]);
