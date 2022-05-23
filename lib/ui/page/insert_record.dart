import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
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
  void initState() {
    recorededAt = DateTime.now();
    temperature = widget.unitPreference == TemperatureUnitPreference.fahrenheit
        ? Temperature.ensureUnit(widget.initialTemperature, Fahrenheit)
        : widget.initialTemperature;
    super.initState();
  }

  bool _get24hEnabled(Box box) => box.get("24h_mode", defaultValue: true);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Box>(
      valueListenable: Hive.box("anitemp_pref").listenable(keys: ["24h_mode"]),
      builder: (context, box, _) => WillPopScope(
          onWillPop: () async {
            return true;
          },
          child: Scaffold(
              appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
              extendBodyBehindAppBar: true,
              body: Padding(
                  padding: const EdgeInsets.all(4),
                  child: ListView(children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ListTile(
                            leading: Text("Record date time: "),
                            title: DateTimeField(
                                dateFormat: DateFormat.yMd(() {
                                  Locale locale =
                                      Localizations.localeOf(context);

                                  String ls = "${locale.languageCode}";

                                  if (locale.countryCode != null) {
                                    ls += "_${locale.countryCode}";
                                  }

                                  return ls;
                                }())
                                    .addPattern(
                                        _get24hEnabled(box) ? "Hms" : "jms"),
                                use24hFormat: _get24hEnabled(box),
                                selectedDate: recorededAt,
                                onDateSelected: (newDateTime) {
                                  setState(() {
                                    recorededAt = newDateTime;
                                  });
                                }),
                            trailing: FittedBox(
                                fit: BoxFit.contain,
                                child: Row(
                                  children: <Widget>[
                                    const Text("24h"),
                                    Switch(
                                        value: _get24hEnabled(box),
                                        onChanged: (newVal) async {
                                          await box.put("24h_mode", newVal);
                                          setState(() {});
                                        })
                                  ],
                                )))),
                    const Divider(),
                  ])))));
}
