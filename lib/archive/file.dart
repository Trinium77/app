import 'dart:io';

import 'package:flutter/foundation.dart' show compute;
import 'package:meta/meta.dart';

import 'codec.dart';

/// Constant of [AnitempFileHandler] with [CompressedAnitempCodec] by default.
const AnitempFileHandler anitempFileHandler = AnitempFileHandler();

/// Extended from [FileSystemException] that the [File] is not a valid Anitemp
/// format.
@sealed
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
  get source {
    try {
      return _file.readAsBytesSync().sublist(0, magicBytesLength);
    } on FileSystemException {
      return null;
    }
  }
}

@sealed
class AnitempFileHandler {
  static const String fileExt = ".atad";
  final AnitempCodec _codec;
  const AnitempFileHandler([this._codec = const CompressedAnitempCodec()]);

  void _extCheck(File file) {
    if (!file.path.endsWith(fileExt)) {
      throw FileSystemException(
          "The file extension must be '.$fileExt'.", file.path);
    }
  }

  Future<File> write(File file, AnitempCodecData data) async {
    _extCheck(file);

    return await compute<AnitempCodecData, File>((d) {
      file.writeAsBytesSync(_codec.encode(d));

      return file;
    }, data);
  }

  Future<AnitempCodecData> read(File file) async {
    _extCheck(file);

    try {
      return await compute<File, AnitempCodecData>(
          (f) => _codec.decode(f.readAsBytesSync()), file);
    } on NotAnitempFormatException {
      throw NotAnitempFileException._(file);
    }
  }
}
