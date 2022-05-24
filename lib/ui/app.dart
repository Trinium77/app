import 'package:anitemp/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/locales.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'page/home.dart';

class AnitempApp extends StatelessWidget {
  const AnitempApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable:
          Hive.box("global_setting").listenable(keys: ["theme_mode", "locale"]),
      builder: (context, Box box, _) {
        Locale locale = box.get("locale");
        return MaterialApp(
            themeMode: box.get("theme_mode"),
            locale: locale,
            localizationsDelegates: <LocalizationsDelegate>[
              LocaleNamesLocalizationsDelegate(),
              AnitempLocales.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            supportedLocales: AnitempLocales.supportedLocales,
            theme: AnitempThemeDataGetter(locale).light,
            darkTheme: AnitempThemeDataGetter(locale).dark,
            home: const AnitempHomepage());
      });
}
