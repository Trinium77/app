import 'hive/start.dart' show initHive;
import 'sql/start.dart' show initSql;

void initDatabases() {
  initSql();
  initHive(boxName: {"global_setting"});
}
