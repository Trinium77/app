part of 'type_adapters.dart';

class _LocaleTypeAdapter extends TypeAdapter<Locale> {
  @override
  final int typeId = 25;

  @override
  Locale read(BinaryReader reader) {
    Map<String, String> localProp = <String, String>{};

    final int mlength = reader.readInt();

    for (int i = 0; i < mlength; i++) {
      localProp[reader.readString()] = reader.readString();
    }

    return Locale.fromSubtags(
        languageCode: localProp["language"]!,
        countryCode: localProp["country"],
        scriptCode: localProp["script"]);
  }

  @override
  void write(BinaryWriter writer, Locale obj) {
    Map<String, String> localProp = <String, String>{
      "language": obj.languageCode
    };

    if (obj.countryCode != null) {
      localProp["country"] = obj.countryCode!;
    }

    if (obj.scriptCode != null) {
      localProp["script"] = obj.scriptCode!;
    }

    writer.writeInt(localProp.length); // Write length
    localProp.forEach((k, v) {
      writer.writeString(k);
      writer.writeString(v);
    });
  }
}
