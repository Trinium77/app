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
  get source {
    try {
      return _file.readAsBytesSync().sublist(0, magicBytesLength);
    } on FileSystemException {
      return null;
    }
  }
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

    return await compute<AnitempCodecData, Uint8List>(_codec.encode, data)
        .then((bytes) => file.writeAsBytes(bytes, flush: true));
  }

  Future<AnitempCodecData> read(File file) async {
    _extCheck(file);

    Uint8List fileData = await file.readAsBytes();

    try {
      return await compute<Uint8List, AnitempCodecData>(
          _codec.decode, fileData);
    } on NotAnitempFormatException {
      throw NotAnitempFileException._(file);
    }
  }
}
