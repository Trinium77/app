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
const CompressedAnitempCodec _compressedAnitempCodec = CompressedAnitempCodec();

get skipTestInCI {
  Map<String, String> env = Platform.environment;
  if (env.containsKey("CI")) {
    return env["TEST_ATDA"] == "1"
        ? false
        : "This test is handled by another action workflow.";
  }
}

Future<void> retainFile(Uint8List bytes, String name) async {
  if (Platform.environment["RETAIN_BINARY"] == "true") {
    File f = File("./dump/$name.bin");

    if (!await f.exists()) {
      f = await f.create(recursive: true);
    }

    f = await f.writeAsBytes(bytes, flush: true);
  }
}

void main() {
  group("Anitemp data archive format test", () {
    group("without compression", () {
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

      test("verify serialized anitemp data", () async {
        expect(
            const ListEquality().equals(tb.sublist(0, 5),
                Uint8List.fromList(<int>[0x96, 0x99, 0x67, 0x97, 0x60])),
            isTrue);
      });

      group("deserialize data", () {
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

        test("record", () {
          ArchivableTemperatureRecordNodeIterable r = deserialized.records;

          expect(r.length, equals(1));

          TemperatureRecordNode rNode = r.first;

          expect(rNode.temperature, equals(Celsius(36.4)));
          expect(
              rNode.recordedAt, equals(DateTime.utc(2022, 3, 1, 12, 34, 31)));
        });

        test("user setting", () {
          UserSetting s = deserialized.userSetting;

          expect(s.unitPreferece,
              equals(TemperatureUnitPreference.uses_recorded_unit));
          expect(s.toleranceCondition, isTrue);
        });
      });

      tearDownAll(() async {
        await retainFile(tb, "atad");
      });
    });

    group("with LZMA", () {
      late final Uint8List ltb;

      setUpAll(() async {
        ltb = await compute(
            _compressedAnitempCodec.encode,
            AnitempCodecData(
                User(name: "Bob", animal: Animal.human, image: null),
                <TemperatureRecordNode>[
                  TemperatureRecordNode(
                      temperature: Fahrenheit(99.2),
                      recordedAt: DateTime.utc(2021, 3, 3, 21, 32, 52)),
                  TemperatureRecordNode(
                      temperature: Celsius(35.5),
                      recordedAt: DateTime.utc(2022, 1, 2, 12, 35, 12))
                ],
                UserSetting.defaultSetting()));
      });

      test("decode with LZMA test", () {
        expect(() async => await compute(_compressedAnitempCodec.decode, ltb),
            returnsNormally);
      });

      tearDownAll(() async {
        await retainFile(ltb, "ataz.lzma");
      });
    });
  }, skip: skipTestInCI);
}
