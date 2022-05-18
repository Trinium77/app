import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'setting.dart' show AnitempSettingPage;

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

      return "${pki.appName} ${pki.version}";
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

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        print("Pop");
        return true;
      },
      child: Scaffold(
          bottomNavigationBar: BottomAppBar(
              child: Stack(
                  alignment: Alignment.centerRight,
                  children: _bottomBarChildren(context)),
              shape: const CircularNotchedRectangle()),
          floatingActionButton: FloatingActionButton(
              onPressed: () {}, child: const Icon(Icons.add)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked));
}
