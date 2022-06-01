import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

abstract class Archivable {
  const Archivable();

  Uint8List toBytes();
}

mixin JsonBasedArchivable on Archivable {
  Map<String, dynamic> get jsonData;

  @mustCallSuper
  @override
  Uint8List toBytes() {
    List<int> encoded = utf8.encode(jsonEncode(jsonData));

    return encoded is Uint8List ? encoded : Uint8List.fromList(encoded);
  }

  static Map<String, dynamic> jbaDecoder(List<int> bytes) =>
      jsonDecode(utf8.decode(bytes));
}
