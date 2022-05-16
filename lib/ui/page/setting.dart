import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_gen/gen_l10n/locals.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:hive_flutter/hive_flutter.dart';

extension on ThemeMode {
  String displayName(BuildContext context) {
    // TODO: Pending localize
    switch (this) {
      case ThemeMode.dark:
      case ThemeMode.light:
        return "${name[0].toUpperCase()}${name.substring(1)}";
      case ThemeMode.system:
        return "Use system's preference";
    }
  }
}

abstract class _AnitempSettingPageBase extends StatefulWidget {
  const _AnitempSettingPageBase({super.key});

  @override
  State<_AnitempSettingPageBase> createState();
}

class AnitempSettingPage extends _AnitempSettingPageBase {
  const AnitempSettingPage({super.key});

  @override
  State<AnitempSettingPage> createState() => _AnitempSettingPageState();
}

abstract class _AnitempSettingPageBaseState<T extends _AnitempSettingPageBase>
    extends State<T> {
  final Box _globalSetting = Hive.box("global_setting");
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @mustCallSuper
  List<Widget> buildSettingOptions(BuildContext context) => [
        ListTile(
            title: Text(
                // TODO: Pending localize
                "Theme mode"),
            trailing: Combobox<ThemeMode>(
                items: ThemeMode.values
                    .map((t) => ComboboxItem<ThemeMode>(
                        value: t, child: Text(t.displayName(context))))
                    .toList(),
                value: _globalSetting.get("theme_mode"),
                onChanged: (newThemeMode) async {
                  if (newThemeMode != null) {
                    await _globalSetting.put("theme_mode", newThemeMode);
                    setState(() {});
                  }
                })),
        ListTile(
            title: Text(
                // TODO: Pending localize
                "Language"),
            trailing: Combobox<Locale>(
                items: AnitempLocales.supportedLocales
                    .map((l) => ComboboxItem<Locale>(
                        value: l,
                        child: Text(LocaleNames.of(context)!.nameOf(() {
                          List<String> localeStr = [l.languageCode];

                          if (l.scriptCode != null) {
                            localeStr.add(l.scriptCode!);
                          }

                          if (l.countryCode != null) {
                            localeStr.add(l.countryCode!);
                          }

                          return localeStr.join("_");
                        }())!)))
                    .toList(),
                value: _globalSetting.get("locale"),
                onChanged: (newLocale) async {
                  if (newLocale != null) {
                    await _globalSetting.put("locale", newLocale);
                    setState(() {});
                  }
                }))
      ];

  @override
  Widget build(BuildContext context) => SafeArea(
      child: ScaffoldPage.scrollable(
          header: PageHeader(title: Text(
              // TODO: Pending localize
              "Setting")),
          children: buildSettingOptions(context),
          scrollController: _controller));
}

class _AnitempSettingPageState
    extends _AnitempSettingPageBaseState<AnitempSettingPage> {}
