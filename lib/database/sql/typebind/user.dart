import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../../../model/animal.dart';
import '../../../model/record.dart' show TemperatureRecordNodeWithId;
import '../../../model/user.dart';
import '../../../model/user_setting.dart';
import '../object.dart' show SQLQueryResult, JsonSQLiteAdapter;
import '../open.dart';
import 'user_setting.dart' show UserSettingWithIdSQLExtension;

/// Extension for interacting SQL and [User].
extension UserSQLiteExtension on User {
  /// Insert new [User] or clone [UserWithId] to the database.
  Future<void> insertUserToDb({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db.insert("anitempuser", jsonDataInSQLite(),
          conflictAlgorithm: ConflictAlgorithm.rollback);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }
}

/// Handle data update of [UserWithId].
extension UserWithIdSQLiteExtension on UserWithId {
  /// Update user's information of current [id].
  Future<void> updateUserIdData({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db.update("anitempuser", jsonDataInSQLite(retainNullValue: true),
          where: "id = ?",
          whereArgs: <Object>[id],
          conflictAlgorithm: ConflictAlgorithm.rollback);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }

  /// Delete **all [UserWithId] and related record (including
  /// [TemperatureRecordNodeWithId] and [UserSettingWithId])** from database.
  ///
  /// This action **can not be reverted** when executed. And this [UserWithId]
  /// should not be used continuously.
  Future<void> deleteUserIdData({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    Batch batch = db.batch()
      ..delete("anitempupref", where: "uid = ?", whereArgs: <Object>[id])
      ..delete("anitemprecord", where: "uid = ?", whereArgs: <Object>[id])
      ..delete("anitempuser", where: "id = ?", whereArgs: <Object>[id]);

    try {
      await batch.commit(noResult: true, continueOnError: false);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }

  Future<UserSettingWithId> getUserSetting({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      return UserSettingWithIdSQLExtension.mapFromSQL(await db
              .query("anitempupref", where: "uid = ?", whereArgs: <Object>[id]))
          .single;
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }

  static List<UserWithId> mapFromSQL(SQLQueryResult sqlData) => sqlData
      .map<UserWithId>((e) => UserWithId(e["id"] as int,
          name: e["name"] as String,
          animal: Animal.values
              .singleWhere((element) => element.name == e["animal"] as String),
          image: e["image"] as Uint8List?))
      .toList(growable: false);
}
