import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void initSql() {
  if (Platform.isLinux || Platform.isWindows) {
    sqfliteFfiInit();
  }

  databaseFactory = databaseFactoryFfi;
}
