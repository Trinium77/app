import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

Future<Directory> getAnitempDatabaseDirectory() async {
  late Directory dbdir;

  try {
    dbdir = await path_provider.getLibraryDirectory();
  } on path_provider.MissingPlatformDirectoryException {
    dbdir = await path_provider
        .getApplicationSupportDirectory()
        .then((asd) => Directory(path.join(asd.path, "db")));

    if (!await dbdir.exists()) {
      dbdir = await dbdir.create(recursive: true);
    }
  }

  return dbdir;
}
