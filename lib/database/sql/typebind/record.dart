import 'dart:collection';

import 'package:sqflite/sqflite.dart';

import '../../../model/record.dart';
import '../../../model/temperature.dart';
import '../../../model/user.dart';
import '../object.dart' show SQLQueryResult;
import '../open.dart';

class QueriedTempreatureRecord
    extends UnmodifiableListView<TemperatureRecordNodeWithId> {
  QueriedTempreatureRecord._(super.source);

  factory QueriedTempreatureRecord(SQLQueryResult result) {
    assert(result.every((r) => <String>["id", "value", "unit", "recorded_at"]
        .every((element) => r.containsKey(element))));

    return QueriedTempreatureRecord._(result.map((e) =>
        TemperatureRecordNodeWithId(e["id"] as int,
            temperature: Temperature.parseSperated(
                e["value"] as double, e["unit"] as String),
            recordedAt: DateTime.parse(e["recorded_at"] as String))));
  }
}

extension TemperatureRecordNodeSQLExtension on TemperatureRecordNode {
  Map<String, Object> get _jsonData => <String, Object>{
        "value": temperature.value,
        "unit": temperature.unit,
        "recorded_at": recordedAt.toIso8601String()
      };

  Future<void> insertRecord(UserWithId user, {bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db.insert("anitemprecord", {"uid": user.id}..addAll(_jsonData),
          conflictAlgorithm: ConflictAlgorithm.rollback);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }
}

extension TemperatureRecordNodeWithIdSQLExtension
    on TemperatureRecordNodeWithId {
  Future<void> updateNode({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db.update("anitemprecord", _jsonData,
          where: "id = ?",
          whereArgs: <Object>[id],
          conflictAlgorithm: ConflictAlgorithm.rollback);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }

  Future<void> deleteNode({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db
          .delete("anitemprecord", where: "id = ?", whereArgs: <Object>[id]);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }
}
