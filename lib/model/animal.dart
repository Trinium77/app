import 'package:meta/meta.dart';

import 'temperature.dart';

enum AnimalTemperatureClassification { hypothermia, normal, hyperthermia }

@immutable
@sealed
class _AnimalMetadata {
  final Temperature lowNormalTemp;
  final Temperature highNormalTemp;
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

enum Animal { human }

extension AnimalExtension on Animal {
  _AnimalMetadata get _metadata {
    switch (this) {
      case Animal.human:
        return _AnimalMetadata.withTolerance(
            Celsius(35), Celsius(37.5), Celsius(40));
    }
  }

  AnimalTemperatureClassification classify(Temperature temperature,
          {bool tolerance = true}) =>
      _metadata._classify(temperature, tolerance);
}
