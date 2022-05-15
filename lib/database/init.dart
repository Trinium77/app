import '../model/global_setting.dart' show globalSettingBoxName;

import 'hive/start.dart' show initHive;
import 'sql/start.dart' show initSql;

void initDatabases() {
  initSql();
  initHive(boxName: {globalSettingBoxName});
}
