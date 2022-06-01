import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as path_provider;

String _getErrorLogContext(Object error) {
  if (error is Error) {
    return error.stackTrace?.toString() ?? error.toString();
  } else if (error is Exception) {
    return error.toString();
  } else if (error is String) {
    return error;
  }

  return "(Thrown as ${error.runtimeType}) $error";
}

void saveErrorLog(Object error, DateTime thrownAt) async {
  String thrownDTStr = DateFormat("yyyyMMddHHmmss").format(thrownAt);

  File log = await path_provider.getApplicationDocumentsDirectory().then(
      (docDir) =>
          File(path.join(docDir.path, "anitemp", "err$thrownDTStr.log")));

  if (!await log.exists()) {
    log = await log.create(recursive: true);
  }

  log = await log.writeAsString(_getErrorLogContext(error), flush: true);
}
