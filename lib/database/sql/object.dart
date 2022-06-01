import 'dart:typed_data';

import '../../archive/archivable.dart' show JsonBasedArchivable;

typedef SQLQueryResult = List<Map<String, Object?>>;

abstract class SQLIdReference {
  int get id;
}

/// An extension converts [Type]s of [jsonData] to SQLite supported one
/// ([int], [double], [String] and [Uint8List]) with some [Type]'s conversion.
extension JsonSQLiteAdapter on JsonBasedArchivable {
  /// Create a new [Map] of [jsonData] with SQLite recognized value type.
  ///
  /// Some types provides conversion as below:
  /// * [bool] will be converted to [int] (`1` and `0`).
  /// * [DateTime] will uses [DateTime.toIso8601String].
  ///
  /// Other types will be rely to [Object.toString].
  ///
  /// [Null] only accepted during updating database. Therefore,
  /// [retainNullValue] will remains all null value in [jsonData] and apply.
  Map<String, dynamic> jsonDataInSQLite({bool retainNullValue = false}) {
    List<MapEntry<String, dynamic>> casted = [];

    for (MapEntry<String, dynamic> e in jsonData.entries) {
      if (e.value != null || retainNullValue) {
        switch (e.value.runtimeType) {
          case bool:
            casted.add(MapEntry(e.key, e.value ? 1 : 0));
            break;
          case DateTime:
            casted
                .add(MapEntry(e.key, (e.value as DateTime).toIso8601String()));
            break;
          case double:
          case int:
          case Uint8List:
          case String:
          case Null:
            casted.add(e);
            break;
          default:
            casted.add(MapEntry(e.key, e.value.toString()));
            break;
        }
      }
    }

    return Map.fromEntries(casted);
  }
}
