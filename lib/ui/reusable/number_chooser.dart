import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../model/temperature.dart';

extension on double {
  List<int> _section() =>
      toStringAsFixed(1).split(".").map(int.parse).toList(growable: false);

  int get integer => _section()[0];

  int get point => _section()[1];
}

class TemperatureChooser extends StatefulWidget {
  final CommonTemperature initialValue;
  final TemperatureUnitPreference unitPreference;
  final void Function(CommonTemperature) onChanges;

  TemperatureChooser(
      {super.key,
      required CommonTemperature initialValue,
      required this.onChanges,
      this.unitPreference = TemperatureUnitPreference.uses_recorded_unit})
      : this.initialValue =
            unitPreference == TemperatureUnitPreference.fahrenheit
                ? Temperature.ensureUnit(initialValue, Fahrenheit)
                : initialValue;

  State<TemperatureChooser> createState() => _TemperatureChooserState();
}

class _TemperatureChooserState extends State<TemperatureChooser> {
  late double _value;
  late Type _unit;
  late int _selectedUnit;

  @override
  CommonTemperature get currentValue {
    switch (_unit) {
      case Celsius:
        return Celsius(_value);
      case Fahrenheit:
        return Fahrenheit(_value);
      default:
        throw TypeError();
    }
  }

  void _valueAssign() {
    this._value = widget.initialValue.value;
    this._unit = widget.initialValue.runtimeType;
  }

  @override
  void initState() {
    _valueAssign();
    _selectedUnit = _unit == Fahrenheit ? 1 : 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
      width: 225,
      height: 250,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[],
                )),
            const Spacer(),
            Expanded(
                flex: 2,
                child: Center(
                  child: ListTile(
                      leading: Text("Unit: ", maxLines: 1),
                      title: ToggleSwitch(
                          initialLabelIndex: _selectedUnit,
                          totalSwitches: 2,
                          labels: const <String>["\u{2103}", "\u{2109}"],
                          onToggle: (idx) {
                            if (idx != null) {
                              setState(() {
                                _selectedUnit = idx;
                              });
                            }
                          })),
                ))
          ]));
}
