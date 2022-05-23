import 'dart:typed_data';

import 'package:sqflite/sqflite.dart';

import '../../../model/animal.dart';
import '../../../model/record.dart' show TemperatureRecordNodeWithId;
import '../../../model/temperature.dart' show TemperatureUnitPreference;
import '../../../model/user.dart';
import '../../../model/user_setting.dart';
import '../object.dart' show SQLQueryResult;
import '../open.dart';

extension UserSQLiteExtension on User {
  /// Insert new [User] or clone [UserWithId] to the database.
  ///
  /// This also initalized default setting of [UserSetting] once [User] insert
  /// to SQL sucessfully.
  Future<void> insertUserToDb({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db.insert("anitempuser", jsonData);

      final int uid = await db
          .query("anitempuser",
              columns: <String>["id"], orderBy: "id DESC", limit: 1)
          .then((r) => r.single["id"] as int);

      await db.insert(
          "anitempupref",
          <String, Object?>{"uid": uid}..addAll(UserSetting(
                  unitPreferece: TemperatureUnitPreference.uses_recorded_unit,
                  toleranceCondition: true)
              .jsonData));
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }
}

extension UserWithIdSQLiteExtension on UserWithId {
  Future<void> updateUserIdData({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db.update("anitempuser", jsonData,
          where: "id = ?", whereArgs: <Object>[id]);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }

  /// Delete **all [UserWithId] and related record (including but not limited to
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
      await batch.commit(noResult: true);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }

  Future<UserSettingWithId> getUserSetting() async {
    throw UnimplementedError();
  }

  static List<UserWithId> mapFromSQL(SQLQueryResult sqlData) => sqlData
      .map<UserWithId>((e) => UserWithId(e["id"] as int,
          name: e["name"] as String,
          animal: Animal.values
              .singleWhere((element) => element.name == e["animal"] as String),
          image: e["image"] as Uint8List?))
      .toList(growable: false);
}
