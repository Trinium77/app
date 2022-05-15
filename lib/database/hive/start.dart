import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:path/path.dart' as path;

import '../path.dart';
import 'type_adapters/type_adapters.dart';

Future<String> get _hiveDirPath async {
  Directory dbdir = await getAnitempDatabaseDirectory();

  Directory hiveDir = Directory(path.join(dbdir.path, "hive"));

  if (!await hiveDir.exists()) {
    await hiveDir.create(recursive: true);
  }

  return hiveDir.path;
}

void initHive(
    {Set<String> boxName = const <String>{},
    Set<String> lazyboxName = const <String>{}}) async {
  assert(boxName.every((bn) => !lazyboxName.contains(bn)),
      "Either box or lazybox only, open both disallowed.");
  await Hive.initFlutter(await _hiveDirPath);
  custom_adapters.forEach((adapters) {
    Hive.registerAdapter(adapters);
  });

  if (boxName.isNotEmpty) {
    for (String bn in boxName) {
      await Hive.openBox(bn);
    }
  }

  if (lazyboxName.isNotEmpty) {
    for (String lbn in lazyboxName) {
      await Hive.openLazyBox(lbn);
    }
  }
}
