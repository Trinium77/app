import 'dart:typed_data';

abstract class Archivable {
  static const String dataDivider =
      "\u{e5be}\u{e4a4}\u{e483}\u{e48c}\u{e4d1}\u{e41d}\u{e510}\u{e4a8}\u{e3c3}\u{e30c}\u{e4ff}\u{e3d4}\u{e364}\u{e5fd}\u{e50f}\u{e3cb}\u{e50f}\u{e5c2}\u{e48a}\u{e39b}\u{e3a5}\u{e31f}\u{e555}\u{e560}\u{e4de}";
  Uint8List toBytes();
}
