import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'database/path.dart';
import 'database/hive/type_adapters.dart';
import 'ui/app.dart';

void main() async {
  if (Platform.isLinux || Platform.isWindows) {
    // Init SQLite dynamic library for Linux and Windows.
    sqfliteFfiInit();
  }

  databaseFactory = databaseFactoryFfi;

  Directory hiveDir = Directory(path.join(await getDatabaseDirPath(), "hive"));

  if (!await hiveDir.exists()) {
    hiveDir = await hiveDir.create(recursive: true);
  }

  await Hive.initFlutter(hiveDir.path);
  registeryAnitempTypeAdpaters(Hive);
  // Init global setting
  var gbs = await Hive.openBox("global_setting");
  // Set initial value
  if (!gbs.containsKey("theme_mode")) {
    await gbs.put("theme_mode", ThemeMode.system);
  }
  if (!gbs.containsKey("locale")) {
    await gbs.put("locale", Locale('en'));
  }

  runApp(const AnitempApp());
}
