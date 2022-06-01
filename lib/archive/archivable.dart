import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Class which implemented [Archivable] can be uses to store data as binary.
abstract class Archivable {
  /// Constructor of [Archivable].
  const Archivable();

  /// Export [Archivable] data to [Uint8List].
  ///
  /// Some mixin likes [JsonBasedArchivable] defined [toBytes]'s implementation
  /// already. It's welcome to add additional [Codec] with `super` called.
  Uint8List toBytes();
}

mixin JsonBasedArchivable on Archivable {
  /// Generate a [Map] as JSON format.
  Map<String, dynamic> get jsonData;

  /// Encode [jsonData] with [utf8] and export as [Uint8List].
  @mustCallSuper
  @override
  Uint8List toBytes() {
    List<int> encoded = utf8.encode(jsonEncode(jsonData));

    return encoded is Uint8List ? encoded : Uint8List.fromList(encoded);
  }

  /// Decode [bytes] to [Map].
  ///
  /// [bytes] must be came from origin [JsonBasedArchivable.toByte].
  static Map<String, dynamic> jbaDecoder(List<int> bytes) =>
      jsonDecode(utf8.decode(bytes));
}
