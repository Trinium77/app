import 'package:fluent_ui/fluent_ui.dart';
import 'package:hive/hive.dart' hide Hive;

class _ThemeModeTypeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 25;

  @override
  ThemeMode read(BinaryReader reader) {
    final int idx = reader.readInt();
    return ThemeMode.values[idx];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeInt(obj.index);
  }
}

class _LocaleTypeAdapter extends TypeAdapter<Locale> {
  @override
  final int typeId = 26;

  @override
  Locale read(BinaryReader reader) {
    final int count = reader.readInt();

    Map<String, String> resolved = {
      for (int c = 0; c < count; c++) reader.readString(): reader.readString()
    };

    return Locale.fromSubtags(
        languageCode: resolved["language"]!,
        countryCode: resolved["country"],
        scriptCode: resolved["script"]);
  }

  @override
  void write(BinaryWriter writer, Locale obj) {
    Map<String, String> lm = {"language": obj.languageCode};

    if (obj.countryCode != null) {
      lm["country"] = obj.countryCode!;
    }

    if (obj.scriptCode != null) {
      lm["script"] = obj.scriptCode!;
    }

    writer.writeInt(lm.length);
    lm.forEach((key, value) {
      writer.writeString(key);
      writer.writeString(value);
    });
  }
}

void registeryAnitempTypeAdpaters(HiveInterface hive) {
  hive.registerAdapter<Locale>(_LocaleTypeAdapter());
  hive.registerAdapter<ThemeMode>(_ThemeModeTypeAdapter());
}
