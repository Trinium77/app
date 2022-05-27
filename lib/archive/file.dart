import 'dart:io';

import 'codec.dart';

class NotAnitempFileException extends FileSystemException
    implements NotAnitempFormatException {
  final File _file;

  NotAnitempFileException._(this._file);

  @override
  String get message =>
      "File '${_file.absolute.path}' is not a valid Anitemp data archive file.";

  @override
  int? get offset => null;

  @override
  get source => _file.readAsBytesSync().sublist(0, magicBytesLength);
}
