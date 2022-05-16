import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../path.dart';

Future<Database> openAnitempSqlite(String filename) async {
  Directory sqliteDir =
      Directory(path.join(await getDatabaseDirPath(), "sqlite"));

  if (!await sqliteDir.exists()) {
    sqliteDir = await sqliteDir.create(recursive: true);
  }

  return openDatabase(
      path.join(sqliteDir.path, "${filename.toLowerCase()}.sqlite3"));
}
