import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

const String _c = "\u{2103}", _f = "\u{2109}";

@immutable
@sealed
abstract class Temperature implements Comparable<Temperature> {
  final double value;

  const Temperature._(this.value)
      : assert(value != double.nan &&
            value != double.infinity &&
            value != double.negativeInfinity);

  String get _unit;

  /// Convert [Temperature]'s [value] to [Kelvin] with same measure.
  Kelvin convertKelvin();

  @override
  int compareTo(Temperature other) {
    Kelvin t = convertKelvin();
    Kelvin o = other.convertKelvin();

    if (t.value > o.value) {
      return 1;
    } else if (t.value < o.value) {
      return -1;
    }

    return 0;
  }

  @override
  int get hashCode =>
      hash2(value, _unit) +
      (value.hashCode + _unit.hashCode) % runtimeType.hashCode;

  @override
  bool operator ==(Object other) {
    if (!(other is Temperature)) {
      return false;
    }

    return hashCode == other.hashCode;
  }

  bool sameMeasure(Temperature other) => compareTo(other) == 0;

  bool operator >(Temperature other) => compareTo(other) > 0;

  bool operator <(Temperature other) => compareTo(other) < 0;

  bool operator >=(Temperature other) => compareTo(other) >= 0;

  bool operator <=(Temperature other) => compareTo(other) <= 0;

  Temperature operator +(Object add);

  Temperature operator -(Object subtract);

  @override
  String toString() => "$value$_unit";

  String toStringFixed() => "${value.toStringAsFixed(1)}$_unit";
}

/// Reference class for [Temperature] conversion.
class Kelvin extends Temperature {
  const Kelvin(double value) : super._(value);

  double _kelvinValue(Object o) {
    if (o is Temperature) {
      return o.convertKelvin().value;
    } else if (o is double) {
      return o;
    }
    throw TypeError();
  }

  @override
  Kelvin operator +(Object add) => Kelvin(value + _kelvinValue(add));

  @override
  Kelvin operator -(Object subtract) => Kelvin(value - _kelvinValue(subtract));

  @override
  String get _unit => "K";

  @override
  Kelvin convertKelvin() => Kelvin(value);
}

extension on Kelvin {
  Celsius toCelsius() => Celsius(value - 273.15);

  Fahrenheit toFahrenheit() => Fahrenheit((value - 273.15) * 9 / 5 + 32);
}

class Celsius extends Temperature {
  const Celsius(double value) : super._(value);

  factory Celsius.fromFahrenheit(Fahrenheit fahrenheit) =>
      Celsius((fahrenheit.value - 32) * 5 / 9);

  @override
  String get _unit => _c;

  @override
  Celsius operator +(Object add) => (convertKelvin() + add).toCelsius();

  @override
  Celsius operator -(Object subtract) =>
      (convertKelvin() - subtract).toCelsius();

  @override
  Kelvin convertKelvin() => Kelvin(value + 273.15);
}

class Fahrenheit extends Temperature {
  const Fahrenheit(double value) : super._(value);

  factory Fahrenheit.fromCelsius(Celsius celsius) =>
      Fahrenheit((celsius.value * 9 / 5) + 32);

  @override
  Fahrenheit operator +(Object add) => (convertKelvin() + add).toFahrenheit();

  @override
  Fahrenheit operator -(Object subtract) =>
      (convertKelvin() - subtract).toFahrenheit();

  @override
  String get _unit => _f;

  @override
  Kelvin convertKelvin() => Kelvin((value - 32) * 5 / 9 + 273.15);
}
