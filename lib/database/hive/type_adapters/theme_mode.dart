part of 'type_adapters.dart';

class _ThemeModeTypeAdapter extends TypeAdapter<ThemeMode> {
  @override
  final int typeId = 24;

  @override
  ThemeMode read(BinaryReader reader) {
    final int themeModeIdx = reader.readInt();
    return ThemeMode.values[themeModeIdx];
  }

  @override
  void write(BinaryWriter writer, ThemeMode obj) {
    writer.writeInt(obj.index);
  }
}
