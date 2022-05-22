import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../model/temperature.dart' hide Kelvin;

class InsertRecordPage extends StatefulWidget {
  final TemperatureUnitPreference unitPreference;
  final CommonTemperature initialTemperature;

  const InsertRecordPage(
      {super.key,
      required this.initialTemperature,
      this.unitPreference = TemperatureUnitPreference.uses_recorded_unit});

  @override
  State<StatefulWidget> createState() => _InsertRecordPageState();
}

class _InsertRecordPageState extends State<InsertRecordPage> {
  late DateTime recorededAt;
  late CommonTemperature temperature;

  @override
  Widget build(BuildContext context) => SafeArea(
          child: Scaffold(
        appBar: AppBar(backgroundColor: const Color(0x00ffffff)),
      ));
}
