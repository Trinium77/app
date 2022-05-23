import 'package:sqflite/sqflite.dart';

import '../../../model/temperature.dart' show TemperatureUnitPreference;
import '../../../model/user_setting.dart';
import '../object.dart' show SQLQueryResult;
import '../open.dart';

extension UserSettingWithIdSQLExtension on UserSettingWithId {
  Future<void> updateSetting({bool keepOpen = false}) async {
    Database db = await openAnitempSqlite();

    try {
      await db.update("anitempupref", jsonData,
          where: "id = ?", whereArgs: <Object>[id]);
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
          toleranceCondition: e["tolerance_condition"] as bool))
      .toList(growable: false);
}
