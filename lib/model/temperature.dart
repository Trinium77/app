import 'package:meta/meta.dart';
import 'package:quiver/core.dart';

const String _c = "\u{2103}", _f = "\u{2109}";

/// An [Enum] to define which [Temperature] unit uses to be displayed.
enum TemperatureUnitPreference {
  /// Uses the same [Temperature] unit when the data recorded.
  uses_recorded_unit,

  /// Always uses [Celsius].
  celsius,

  /// Always uses [Fahrenheit].
  fahrenheit
}

/// A unit uses for measure animal's body [Temperature].
///
/// It comes 3 types of [Temperature]: [Celsius], [Fahrenheit] and [Kelvin].
///
/// [Kelvin] uses as base reference of various [Temperature] units which
/// **should be uses internally**. For [Temperature] which suitable for
/// implementing in user layer, see [CommonTemperature].
@immutable
@sealed
abstract class Temperature implements Comparable<Temperature> {
  /// Value of current [Temperature].
  ///
  /// [value] can not be [double.nan], [double.negativeInfinity] and
  /// [double.infinity].
  final double value;

  const Temperature._(this.value)
      : assert(value != double.nan &&
            value != double.infinity &&
            value != double.negativeInfinity);

  /// Construct a [Temperature] with [value] and [unit] provided speratedly.
  static CommonTemperature parseSperated(double value, String unit) {
    switch (unit) {
      case _c:
      case "C":
        return Celsius(value);
      case _f:
      case "F":
        return Fahrenheit(value);
      default:
        throw FormatException("Unknown temperature unit found", unit);
    }
  }

  /// Construct a [Temperature] with provide [value] with unit included.
  static CommonTemperature parse(String value) {
    List<String> tus = value.split("\u{00B0}");

    switch (tus.length) {
      case 1:
        double v = double.parse(value.substring(0, value.length - 1));
        return parseSperated(v, value[value.length - 1]);
      case 2:
        return parseSperated(double.parse(tus[0]), tus[1]);
      default:
        throw FormatException("Invalid temperature value expression", value);
    }
  }

  /// [Temperature]'s unit symbol.
  String get unit;

  /// Convert [Temperature]'s [value] to [Kelvin] with same measure.
  Kelvin convertKelvin();

  /// Compare [other] [Temperature] under the same unit in [Kelvin].
  ///
  /// It returns positive number if `this` is greater than [other], negative
  /// number if `this` is lower than [other] or `0` if both under same measure.
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
      hash2(value, unit) +
      (value.hashCode + unit.hashCode) % runtimeType.hashCode;

  /// Check [Temperature] has **exact same** data of [other].
  ///
  /// For comparing under same measure, please uses [sameMeasure].
  @override
  bool operator ==(Object other) {
    if (!(other is Temperature)) {
      return false;
    }

    return hashCode == other.hashCode;
  }

  /// Check `this` has the same measure with [other].
  bool sameMeasure(Temperature other) => compareTo(other) == 0;

  /// Check `this` is greater than [other].
  bool operator >(Temperature other) => compareTo(other) > 0;

  /// Check `this` is lower than [other].
  bool operator <(Temperature other) => compareTo(other) < 0;

  /// Check `this` is greater or equal with [other].
  bool operator >=(Temperature other) => compareTo(other) >= 0;

  /// Check `this` is lowerer or equal with [other].
  bool operator <=(Temperature other) => compareTo(other) <= 0;

  /// Plus [Temperature] with [add] given.
  ///
  /// Throws [TypeError] if neither [double] nor [Temperature] applied as [add].
  Temperature operator +(Object add);

  /// Minus [Temperature] with [subtract] given.
  ///
  /// Throws [TypeError] if neither [double] nor [Temperature] applied as
  /// [subtract].
  Temperature operator -(Object subtract);

  /// Display [Temperature]'s completed [value] and [unit] in [String].
  @override
  String toString() => "$value$unit";

  /// Display [Temperature]'s [value] with fixed 1 decimal point and [unit] in
  /// [String].
  String toStringFixed() => "${value.toStringAsFixed(1)}$unit";
}

/// A mixin of [Temperaure] which can be implemented under user layer.
mixin CommonTemperature on Temperature {
  /// Convert [Temperature] to a [String] as accessible text.
  String toAccessibleString({bool fixed = true}) {
    String vs = fixed ? value.toStringAsFixed(1) : value.toString();

    return "$vs degree $runtimeType";
  }
}

/// Reference class for [Temperature] conversion.
class Kelvin extends Temperature {
  /// Construct a new [Kelvin] with given [value].
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
  String get unit => "K";

  @override
  Kelvin convertKelvin() => Kelvin(value);
}

extension on Kelvin {
  /// Convert from [Kelvin] to [Celsius].
  Celsius toCelsius() => Celsius(value - 273.15);

  /// Convert from [Kelvin] to [Fahrenheit].
  Fahrenheit toFahrenheit() => Fahrenheit((value - 273.15) * 9 / 5 + 32);
}

/// International standard unit uses for [Temperature].
class Celsius extends Temperature with CommonTemperature {
  /// Construct [Celsius].
  const Celsius(double value) : super._(value);

  /// Construct [Celsius] from [Fahrenheit].
  factory Celsius.fromFahrenheit(Fahrenheit fahrenheit) =>
      Celsius((fahrenheit.value - 32) * 5 / 9);

  @override
  String get unit => _c;

  @override
  Celsius operator +(Object add) => (convertKelvin() + add).toCelsius();

  @override
  Celsius operator -(Object subtract) =>
      (convertKelvin() - subtract).toCelsius();

  @override
  Kelvin convertKelvin() => Kelvin(value + 273.15);
}

/// Another common uses [Temperature] unit.
class Fahrenheit extends Temperature with CommonTemperature {
  /// Construct [Fahrenheit].
  const Fahrenheit(double value) : super._(value);

  /// Construct [Fahrenheit] from [Celsius].
  factory Fahrenheit.fromCelsius(Celsius celsius) =>
      Fahrenheit((celsius.value * 9 / 5) + 32);

  @override
  Fahrenheit operator +(Object add) => (convertKelvin() + add).toFahrenheit();

  @override
  Fahrenheit operator -(Object subtract) =>
      (convertKelvin() - subtract).toFahrenheit();

  @override
  String get unit => _f;

  @override
  Kelvin convertKelvin() => Kelvin((value - 32) * 5 / 9 + 273.15);
}
