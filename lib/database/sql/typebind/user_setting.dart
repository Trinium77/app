import 'package:sqflite/sqflite.dart';

import '../../../model/temperature.dart' show TemperatureUnitPreference;
import '../../../model/user.dart' show UserWithId;
import '../../../model/user_setting.dart';
import '../object.dart' show SQLQueryResult, JsonSQLiteAdapter;
import '../open.dart';

extension UserSettingSQLExtension on UserSetting {
  Future<void> insertSettingToUser(
      {UserWithId? user, bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      int uid = user?.id ??
          await db
              .query("anitempuser",
                  columns: <String>["id"], orderBy: "id DESC", limit: 1)
              .then((r) => r.single["id"] as int);

      await db.insert("anitempupref",
          <String, Object?>{"uid": uid}..addAll(jsonDataInSQLite()),
          conflictAlgorithm: ConflictAlgorithm.rollback);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }
}

extension UserSettingWithIdSQLExtension on UserSettingWithId {
  Future<void> updateSetting({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db.update("anitempupref", jsonDataInSQLite(retainNullValue: true),
          where: "id = ?",
          whereArgs: <Object>[id],
          conflictAlgorithm: ConflictAlgorithm.rollback);
    } finally {
      if (!keepOpen) {
        await db.close();
      }
    }
  }

  static List<UserSettingWithId> mapFromSQL(SQLQueryResult sqlData) => sqlData
      .map((e) => UserSettingWithId(e["id"] as int,
          unitPreferece: TemperatureUnitPreference.values.singleWhere(
              (element) => element.name == e["unit_preference"] as String),
          toleranceCondition: e["tolerance_condition"] as int == 1))
      .toList(growable: false);
}
