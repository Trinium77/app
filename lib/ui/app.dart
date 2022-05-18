import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/locals.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'page/home.dart';
import 'theme/theme.dart' show AnitempThemeData;

class AnitempApp extends StatelessWidget {
  const AnitempApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable:
          Hive.box("global_setting").listenable(keys: ["theme_mode", "locale"]),
      builder: (context, Box box, _) => MaterialApp(
          themeMode: box.get("theme_mode"),
          locale: box.get("locale"),
          localizationsDelegates: <LocalizationsDelegate>[
            LocaleNamesLocalizationsDelegate(),
            AnitempLocales.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: AnitempLocales.supportedLocales,
          theme: AnitempThemeData.light(),
          darkTheme: AnitempThemeData.dark(),
          home: const AnitempHomepage()));
}
