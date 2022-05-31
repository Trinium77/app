import 'dart:io';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:flutter_test/flutter_test.dart';
import 'package:anitemp/archive/codec.dart';
import 'package:anitemp/model/animal.dart';
import 'package:anitemp/model/record.dart';
import 'package:anitemp/model/temperature.dart';
import 'package:anitemp/model/user.dart';
import 'package:anitemp/model/user_setting.dart';

const AnitempCodec _anitemp = AnitempCodec();

void main() {
  late final Uint8List tb;

  setUpAll(() async {
    tb = await compute(
        _anitemp.encode,
        AnitempCodecData(
            User(name: "Alice", animal: Animal.human, image: null),
            <TemperatureRecordNode>[
              TemperatureRecordNode(
                  temperature: Celsius(36.4),
                  recordedAt: DateTime.utc(2022, 3, 1, 12, 34, 31))
            ],
            UserSetting.defaultSetting()));
  });

  test("Verify serialized anitemp data", () async {
    expect(
        const ListEquality().equals(tb.sublist(0, 5),
            Uint8List.fromList(<int>[0x96, 0x99, 0x67, 0x97, 0x60])),
        isTrue);
  });

  group("Deserialize data", () {
    late final AnitempCodecData deserialized;

    setUpAll(() async {
      deserialized = await compute(_anitemp.decode, tb);
    });

    test("user", () {
      User u = deserialized.user;

      expect(u.name, equals("Alice"));
      expect(u.animal, equals(Animal.human));
      expect(u.image, isNull);
    });
  });
}
