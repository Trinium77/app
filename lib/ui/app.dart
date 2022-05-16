import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/adapters.dart';

import 'page/home.dart';

class AnitempApp extends StatelessWidget {
  const AnitempApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
      valueListenable:
          Hive.box("global_setting").listenable(keys: ["theme_mode", "locale"]),
      builder: (context, Box box, _) => FluentApp(
            themeMode: box.get("theme_mode"),
            locale: box.get("locale"),
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
            home: const AnitempHomepage(),
          ));
}
