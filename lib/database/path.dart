import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

Future<String> getDatabaseDirPath() async {
  Directory dbdir;

  try {
    dbdir = await path_provider.getLibraryDirectory();
  } on UnimplementedError catch (_) {
    dbdir = Directory(path.join(
        await path_provider
            .getApplicationSupportDirectory()
            .then((dir) => dir.path),
        "db"));

    if (!await dbdir.exists()) {
      dbdir = await dbdir.create(recursive: true);
    }
  }

  return dbdir.path;
}
