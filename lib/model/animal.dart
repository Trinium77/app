import 'package:meta/meta.dart';

import 'temperature.dart';

/// An [Enum] of classification of body [Temperature] of different [Animal].
enum AnimalTemperatureClassification {
  /// Body [Temperature] is under normal range of [Animal].
  hypothermia,

  /// Body [Temperature] is stastified for [Animal].
  normal,

  /// Body [Temperature] is higher normal range of [Animal] (a.k.a fever).
  hyperthermia
}

/// A metadata contains various [Animal]'s body [Temperature] range.
@immutable
@sealed
class _AnimalMetadata {
  /// Lowest [Temperature] point of normal temperature.
  final Temperature lowNormalTemp;

  /// Highest [Temperature] point of normal temperature.
  final Temperature highNormalTemp;

  /// Another highest [Temperature] point of normal temperature.
  ///
  /// If it provided, it must be higher than [highNormalTemp].
  final Temperature highToleranceNormalTemp;

  const _AnimalMetadata(this.lowNormalTemp, this.highNormalTemp)
      : assert(lowNormalTemp < highNormalTemp),
        this.highToleranceNormalTemp = highNormalTemp;

  const _AnimalMetadata.withTolerance(
      this.lowNormalTemp, this.highNormalTemp, this.highToleranceNormalTemp)
      : assert(lowNormalTemp < highNormalTemp),
        assert(highToleranceNormalTemp > highNormalTemp);

  AnimalTemperatureClassification _classify(
      Temperature temperature, bool tolerance) {
    if (temperature < lowNormalTemp) {
      return AnimalTemperatureClassification.hypothermia;
    }

    Temperature hNT = tolerance ? highToleranceNormalTemp : highNormalTemp;

    if (temperature > hNT) {
      return AnimalTemperatureClassification.hyperthermia;
    }

    return AnimalTemperatureClassification.normal;
  }
}

/// Warm-blood [Animal] type supported in Anitemp.
enum Animal {
  human(Celsius(37));

  /// Default [Temperature] display when opened record page.
  final Temperature defaultTemperature;

  const Animal(this.defaultTemperature);
}

/// An extension for getting data with [Animal].
extension AnimalExtension on Animal {
  _AnimalMetadata get _metadata {
    switch (this) {
      case Animal.human:
        return _AnimalMetadata.withTolerance(
            Celsius(35), Celsius(37.5), Celsius(40));
    }
  }

  /// Classify the [temperature] for [Animal].
  ///
  /// If [tolerance] set `false`, the condition of
  /// [AnimalTemperatureClassification.hyperthermia] will be lowered.
  AnimalTemperatureClassification classify(Temperature temperature,
          {bool tolerance = true}) =>
      _metadata._classify(temperature, tolerance);
}
