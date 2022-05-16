import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/locals.dart';
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
      builder: (context, Box box, _) => FluentApp(
          themeMode: box.get("theme_mode"),
          locale: box.get("locale"),
          localizationsDelegates: [
            LocaleNamesLocalizationsDelegate(),
            AnitempLocales.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],
          supportedLocales: AnitempLocales.supportedLocales,
          localeListResolutionCallback: (providedLocale, supportedLocale) {
            if (providedLocale != null) {
              for (Locale l in providedLocale) {
                if (supportedLocale.contains(l)) {
                  return l;
                }
              }
            }

            return Locale('en');
          },
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: const AnitempHomepage()));
}
