import 'package:anitemp/model/temperature.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Temperature expression", () {
    test("generate accessable string", () {
      expect(Celsius(37).toAccessibleString(), equals("37.0 degree Celsius"));
      expect(Fahrenheit(99.34).toAccessibleString(),
          equals("99.3 degree Fahrenheit"));
    });
    test("print to console", () {
      expect(Celsius(34), equals("34\u{2103}"));
      expect(Fahrenheit(95.6), equals("95.6\u{2109}"));
    });
  });
}
