import 'package:anitemp/model/animal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sqflite/sqflite.dart';

import '../../database/sql/object.dart';
import '../../database/sql/open.dart';
import '../../database/sql/typebind/user.dart';
import '../../model/temperature.dart';
import '../../model/user.dart';
import '../page/user_info.dart';
import '../reusable/avatar.dart';
import '../reusable/close_confirm.dart';
import '../reusable/error_dialog.dart';
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

      return "${pki.appName} ${pki.version}    (actual version: $_actualVersion)";
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

    if (action == null) {
      return;
    }

    switch (action) {
      case _AddUserAction.create:
        if (await Navigator.push<bool>(context,
                MaterialPageRoute(builder: (context) => NewUserPage())) ??
            false) {
          setState(() {});
        }
        break;
      case _AddUserAction.import:
        // TODO: Handle this case.
        break;
    }
  }

  Future<List<UserWithId>> get _currentUserInfo async {
    Database db = await openAnitempSqlite();

    try {
      return UserWithIdSQLiteExtension.mapFromSQL(
          await db.query("anitempuser"));
    } finally {
      await db.close();
    }
  }

  Widget _userInfoBuilder(List<UserWithId> uwid) {
    if (uwid.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
              padding: EdgeInsets.only(bottom: 36),
              child: SizedBox.square(
                  dimension: 125,
                  child: FittedBox(child: Icon(FontAwesomeIcons.userPen)))),
          Text("Press '+' button to create user.",
              style: const TextStyle(fontSize: 24))
        ],
      );
    }

    return LayoutBuilder(builder: (context, constraint) {
      int ipc = 2;

      if (constraint.maxWidth > 940) {
        ipc = 5;
      } else if (constraint.maxWidth > 768) {
        ipc = 4;
      } else if (constraint.maxWidth > 576) {
        ipc = 3;
      }

      return GridView.builder(
          shrinkWrap: true,
          itemCount: uwid.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: ipc),
          itemBuilder: (context, idx) {
            final UserWithId u = uwid[idx];
            List<Widget> userContainer = <Widget>[
              Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AvatarDisplayer(u.image, radius: 50)),
              Text(u.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w500))
            ];

            return SizedBox.square(
                dimension: 75,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: userContainer));
          });
    });
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
            child: FutureBuilder<List<UserWithId>>(
          future: _currentUserInfo,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator()),
                      Text("Getting user informations...")
                    ]);
              case ConnectionState.done:
                if (snapshot.hasData) {
                  return _userInfoBuilder(snapshot.data!);
                } else if (snapshot.hasError) {
                  DateTime errTime = DateTime.now();
                  String errMsg =
                      "Something wrong when loading user information.";

                  Future.delayed(Duration.zero,
                      () => showErrorDialog(context, snapshot.error!, errMsg));

                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const Padding(
                            padding: EdgeInsets.only(bottom: 18),
                            child:
                                Icon(FontAwesomeIcons.notesMedical, size: 48)),
                        Text(errMsg, textAlign: TextAlign.center)
                      ]);
                }

                return Center();
            }
          },
        )),
      ));
}
