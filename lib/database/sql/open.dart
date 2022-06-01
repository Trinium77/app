import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../path.dart';

bool anitempDBTestMode = false;

Future<Database> openAnitempSqlite() async {
  Directory sqliteDir =
      Directory(path.join(await getDatabaseDirPath(), "sqlite"));

  if (!await sqliteDir.exists()) {
    sqliteDir = await sqliteDir.create(recursive: true);
  }

  return openDatabase(
      path.join(
          anitempDBTestMode ? "./test_db" : sqliteDir.path, "anitemp.sqlite3"),
      version: 1, onConfigure: (db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }, onCreate: (db, version) async {
    await db.execute(
        '''
CREATE TABLE anitempuser (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  animal TEXT NOT NULL,
  image BLOB
)
''');
    await db.execute(
        '''
CREATE TABLE anitemprecord (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  uid INTEGER NOT NULL,
  value REAL NOT NULL,
  unit TEXT NOT NULL,
  recorded_at TEXT NOT NULL,
  FOREIGN KEY (uid) REFERENCES anitempuser (id)
)
''');
    await db.execute(
        '''
CREATE TABLE anitempupref (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  uid INTEGER NOT NULL UNIQUE,
  unit_preference TEXT NOT NULL,
  tolerance_condition BOOLEAN NOT NULL CHECK (tolerance_condition IN (0, 1)),
  FOREIGN KEY (uid) REFERENCES anitempuser (id)
)
''');
  });
}
