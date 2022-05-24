import 'package:anitemp/model/temperature.dart';
import 'package:anitemp/ui/page/insert_record.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../reusable/close_confirm.dart';
import 'setting.dart' show AnitempSettingPage;

const String _actualVersion = "0.0.0-alpha+1";

enum _AddUserAction { create, import }

class AnitempHomepage extends StatefulWidget {
  const AnitempHomepage({super.key});

  @override
  State<AnitempHomepage> createState() => _AnitempHomepageState();
}

class _AnitempHomepageState extends State<AnitempHomepage> {
  late final Future<String> _debugInfo;

  @override
  void initState() {
    super.initState();
    _debugInfo = () async {
      PackageInfo pki = await PackageInfo.fromPlatform();

      return "${pki.appName} ${pki.version}\t(actual version: $_actualVersion)";
    }();
  }

  List<Widget> _bottomBarChildren(BuildContext context) {
    final List<Widget> c = <Widget>[
      IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => AnitempSettingPage()));
          },
          icon: const Icon(Icons.settings))
    ];

    if (kDebugMode) {
      c.insert(
          0,
          Positioned(
              left: 0,
              bottom: 0,
              child: FutureBuilder<String>(
                  future: _debugInfo,
                  builder: ((context, snapshot) => Text(
                      snapshot.hasData
                          ? snapshot.data!
                          : "", // Show nothing if load failed
                      style: const TextStyle(
                          fontSize: 9.5, fontWeight: FontWeight.w300))))));
    }

    return c;
  }

  void _newUserAction(BuildContext context) async {
    _AddUserAction? action = await showDialog(
        context: context,
        builder: (context) => SimpleDialog(title: Text(
                // TODO: Localize
                "Add user"), children: <Widget>[
              ListTile(
                  leading: const Icon(Icons.person_add_alt_sharp),
                  title: Text(

                      /// TODO: Localize
                      "Create new user"),
                  onTap: () => Navigator.pop(context, _AddUserAction.create)),
              const Divider(),
              ListTile(
                  leading: const Icon(Icons.file_download),
                  title: Text(

                      /// TODO: Localize
                      "Import user..."),
                  onTap: () => Navigator.pop(context, _AddUserAction.import))
            ]));
  }

  @override
  Widget build(BuildContext context) => CloseConfirmScaffold(
          scaffold: Scaffold(
        bottomNavigationBar: BottomAppBar(
            child: Stack(
                alignment: Alignment.centerRight,
                children: _bottomBarChildren(context)),
            shape: const CircularNotchedRectangle()),
        floatingActionButton: FloatingActionButton(
            tooltip: "Add user", // TODO: Localize
            onPressed: () => _newUserAction(context),
            child: const Icon(Icons.add)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: Center(
          child: TextButton(
              child: Text("open rec page"),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            InsertRecordPage(initialTemperature: Celsius(37))));
              }),
        ),
      ));
}
