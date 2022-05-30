import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'codec.dart';

const AnitempFileHandler anitempFileHandler = AnitempFileHandler();

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

    return await compute<File, AnitempCodecData>(
        (f) => _codec.decode(f.readAsBytesSync()), file);
  }
}
