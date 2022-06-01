import 'package:flutter_test/flutter_test.dart';
import 'package:collection/collection.dart' show ListEquality;

import 'package:anitemp/model/record.dart';
import 'package:anitemp/model/temperature.dart';

void main() {
  group("Sorting test", () {
    late List<TemperatureRecordNode> ltn;

    setUp(() {
      ltn = <TemperatureRecordNode>[
        TemperatureRecordNode(
            temperature: Celsius(37),
            recordedAt: DateTime.utc(2020, 1, 1, 12, 30, 50)),
        TemperatureRecordNode(
            temperature: Celsius(36.4),
            recordedAt: DateTime.utc(2020, 2, 6, 23, 43, 18)),
        TemperatureRecordNode(
            temperature: Celsius(36.9),
            recordedAt: DateTime.utc(2020, 6, 21, 15, 52, 29)),
        TemperatureRecordNode(
            temperature: Fahrenheit(100),
            recordedAt: DateTime.utc(2020, 7, 13, 6, 19, 47)),
        TemperatureRecordNode(
            temperature: Fahrenheit(97.3),
            recordedAt: DateTime.utc(2020, 9, 23, 3, 34, 8))
      ];
    });

    test("order by temperature", () {
      ltn.sortByTemperature();
      expect(
          const ListEquality().equals(
              ltn.map((e) => e.temperature).toList(), const <CommonTemperature>[
            Fahrenheit(100),
            Celsius(37),
            Celsius(36.9),
            Celsius(36.4),
            Fahrenheit(97.3)
          ]),
          isTrue);
    });

    test("order by datetime", () {
      ltn.sortByRecordedAt();
      expect(
          const ListEquality().equals(
              ltn.map((e) => e.temperature).toList(), const <CommonTemperature>[
            Fahrenheit(97.3),
            Fahrenheit(100),
            Celsius(36.9),
            Celsius(36.4),
            Celsius(37)
          ]),
          isTrue);
    });
  });
}
