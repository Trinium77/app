import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/locals.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../reusable/labeled_divider.dart';

extension on ThemeMode {
  String displayName(BuildContext context) {
    switch (this) {
      case ThemeMode.dark:
        return AnitempLocales.of(context).setting_theme_mode_dark;
      case ThemeMode.light:
        return AnitempLocales.of(context).setting_theme_mode_light;
      case ThemeMode.system:
        return AnitempLocales.of(context).setting_theme_mode_system;
    }
  }
}

abstract class AnitempSettingPage implements StatefulWidget {
  const factory AnitempSettingPage({Key? key}) = _AnitempSettingPage;

  factory AnitempSettingPage.withUser(dynamic user, {Key? key}) =
      _AnitempUserSettingPage;

  @override
  State<AnitempSettingPage> createState();
}

abstract class _AnitempSettingPageBaseState<T extends AnitempSettingPage>
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
  List<Widget> buildSettingOptions(BuildContext context) => <Widget>[
        ListTile(
            title: Text(AnitempLocales.of(context).setting_theme_mode),
            trailing: SizedBox(
                width: 200,
                child: DropdownButton<ThemeMode>(
                    isExpanded: true,
                    items: ThemeMode.values
                        .map((t) => DropdownMenuItem<ThemeMode>(
                            value: t, child: Text(t.displayName(context))))
                        .toList(),
                    value: _globalSetting.get("theme_mode"),
                    onChanged: (newThemeMode) async {
                      if (newThemeMode != null) {
                        await _globalSetting.put("theme_mode", newThemeMode);
                        setState(() {});
                      }
                    }))),
        ListTile(
            title: Text(AnitempLocales.of(context).setting_language),
            trailing: SizedBox(
                width: 300,
                child: DropdownButton<Locale>(
                    isExpanded: true,
                    items: AnitempLocales.supportedLocales
                        .map((l) => DropdownMenuItem<Locale>(
                            value: l,
                            child: Text(
                                LocaleNames.of(context)!.nameOf(
                                    l.toLanguageTag().replaceAll("-", "_"))!,
                                style: const TextStyle(fontSize: 12.5))))
                        .toList(),
                    value: _globalSetting.get("locale"),
                    onChanged: (newLocale) async {
                      if (newLocale != null) {
                        await _globalSetting.put("locale", newLocale);
                        setState(() {});
                      }
                    })))
      ];

  @override
  Widget build(BuildContext context) => SafeArea(
      child: Scaffold(
          appBar: AppBar(title: Text(AnitempLocales.of(context).setting)),
          body: ListView(children: buildSettingOptions(context))));
}

class _AnitempSettingPage extends StatefulWidget implements AnitempSettingPage {
  const _AnitempSettingPage({super.key});

  @override
  State<_AnitempSettingPage> createState() => _AnitempSettingPageState();
}

class _AnitempSettingPageState
    extends _AnitempSettingPageBaseState<_AnitempSettingPage> {}

class _AnitempUserSettingPage extends StatefulWidget
    implements AnitempSettingPage {
  final user;

  _AnitempUserSettingPage(this.user, {super.key});

  @override
  State<_AnitempUserSettingPage> createState() =>
      _AnitempUserSettingPageState();
}

enum _AnitempUserSettingLeaveAction { save, without_save, cancel }

class _AnitempUserSettingPageState
    extends _AnitempSettingPageBaseState<_AnitempUserSettingPage> {
  late bool modified;

  @override
  void initState() {
    super.initState();
    modified = false;
  }

  @override
  List<Widget> buildSettingOptions(BuildContext context) {
    List<Widget> userSection = <Widget>[
      LabeledDivider(
          label:
              // TODO: Localize
              "User Setting"),
      LabeledDivider(
          label:
              // TODO: Localize
              "App Setting")
    ];
    return userSection..addAll(super.buildSettingOptions(context));
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        if (!modified) {
          return true;
        }

        _AnitempUserSettingLeaveAction leaveAction = await showDialog<
                    _AnitempUserSettingLeaveAction>(
                context: context,
                builder: (context) => AlertDialog(
                        title: Text(
                            // TODO: Localize
                            "Leave setting"),
                        content: Text(
                            // TODO: Localize
                            "Do you want to save modified user data?"),
                        actions: <TextButton>[
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop<_AnitempUserSettingLeaveAction>(
                                      context,
                                      _AnitempUserSettingLeaveAction.save),
                              child: Text(
                                  // TODO: Localize
                                  "Save")),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop<_AnitempUserSettingLeaveAction>(
                                      context,
                                      _AnitempUserSettingLeaveAction
                                          .without_save),
                              child: Text(
                                  // TODO: Localize
                                  "Don't save")),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop<_AnitempUserSettingLeaveAction>(
                                      context,
                                      _AnitempUserSettingLeaveAction.cancel),
                              child: Text(
                                  // TODO: Localize
                                  "Cancel"))
                        ])) ??
            _AnitempUserSettingLeaveAction.cancel;

        switch (leaveAction) {
          case _AnitempUserSettingLeaveAction.save:
          case _AnitempUserSettingLeaveAction.without_save:
            return true;
          case _AnitempUserSettingLeaveAction.cancel:
            return false;
        }
      },
      child: super.build(context));
}
