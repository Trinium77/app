import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../../model/temperature.dart' hide Kelvin;
import '../theme/colour.dart';

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
  static const List<String> _unitLbl = const <String>["\u{2103}", "\u{2109}"];
  static const double _paddingHori = 12;
  static const TextStyle _actionBtnTxtStyle = TextStyle(fontSize: 18);
  static const EdgeInsets _actionBtnPadding =
      EdgeInsets.symmetric(vertical: 6, horizontal: 10);

  late DateTime recorededAt;
  late CommonTemperature temperature;
  late Tween<double> _tfTween;
  late final TextEditingController _controller;
  late bool _submit;

  @override
  void initState() {
    _submit = false;
    recorededAt = DateTime.now();
    temperature = widget.unitPreference == TemperatureUnitPreference.fahrenheit
        ? Temperature.ensureUnit(widget.initialTemperature, Fahrenheit)
        : widget.initialTemperature;
    _tfTween = Tween<double>(begin: 24, end: 24);
    super.initState();
    _controller =
        TextEditingController(text: temperature.value.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _get24hEnabled(Box box) => box.get("24h_mode", defaultValue: true);

  void _onTextFieldChanged(String newVal) {
    if (newVal.isNotEmpty) {
      setState(() {
        double nvid = double.parse(newVal);
        switch (temperature.runtimeType) {
          case Celsius:
            temperature = Celsius(nvid);
            break;
          case Fahrenheit:
            temperature = Fahrenheit(nvid);
            break;
          default:
            throw TypeError();
        }
      });
    }
  }

  void _onUnitToggle(int? newUnit) {
    if (newUnit != null) {
      setState(() {
        switch (newUnit) {
          case 0:
            temperature = Temperature.ensureUnit(temperature, Celsius);
            break;
          case 1:
            temperature = Temperature.ensureUnit(temperature, Fahrenheit);
            break;
          default:
            throw IndexError(newUnit, _unitLbl);
        }
        _controller.text = temperature.value.toStringAsFixed(1);
      });
    }
  }

  Text _dtfLbl(BuildContext context) => Text(
      // TODO: Localize
      "Record date time: ");

  DateTimeField _dtf(Box box, BuildContext context) => DateTimeField(
      dateFormat: DateFormat.yMd(() {
        Locale locale = Localizations.localeOf(context);

        String ls = "${locale.languageCode}";

        if (locale.countryCode != null) {
          ls += "_${locale.countryCode}";
        }

        return ls;
      }())
          .addPattern(_get24hEnabled(box) ? "Hms" : "jms"),
      use24hFormat: _get24hEnabled(box),
      selectedDate: recorededAt,
      onDateSelected: (newDateTime) {
        setState(() {
          recorededAt = newDateTime;
        });
      });

  Row _switch24h(Box box, BuildContext context,
          {MainAxisAlignment? mainAxisAlignment,
          CrossAxisAlignment? crossAxisAlignment}) =>
      Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: <Widget>[
          const Text("24h"),
          Switch(
              value: _get24hEnabled(box),
              onChanged: (newVal) async {
                await box.put("24h_mode", newVal);
                setState(() {});
              })
        ],
      );

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Box>(
      valueListenable: Hive.box("anitemp_pref").listenable(keys: ["24h_mode"]),
      builder: (context, box, _) => WillPopScope(
          onWillPop: () async {
            if (!_submit) {
              return true;
            }

            if (_controller.text.isEmpty) {
              await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: Text(
                            // TODO: Localize
                            "Please enter body temperature"),
                        actions: <TextButton>[
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text("OK"))
                        ],
                      ));
              setState(() {
                _submit = false;
              });
              return false;
            }

            return true;
          },
          child: Scaffold(
              appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: IconThemeData(
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.light
                          ? Colors.black
                          : null)),
              body: ListView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: _paddingHori, vertical: 4),
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: LayoutBuilder(
                            builder: (context, constraints) => constraints
                                        .maxWidth >
                                    500
                                ? ListTile(
                                    leading: _dtfLbl(context),
                                    title: _dtf(box, context),
                                    trailing: FittedBox(
                                        fit: BoxFit.contain,
                                        child: _switch24h(box, context,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center)))
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                                padding:
                                                    EdgeInsetsDirectional.only(
                                                        end: 12),
                                                child: _dtfLbl(context)),
                                            Expanded(child: _dtf(box, context))
                                          ]),
                                      _switch24h(box, context,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center)
                                    ],
                                  ))),
                    const Divider(),
                    Text(
                        // TODO: Localize
                        "Body temperature",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w300)),
                    SizedBox(
                        height: 80,
                        child: FocusScope(
                            child: Focus(
                                onFocusChange: (focus) {
                                  setState(() {
                                    _tfTween = focus
                                        ? Tween<double>(begin: 24, end: 63)
                                        : Tween<double>(begin: 63, end: 24);
                                  });
                                },
                                child: TweenAnimationBuilder<double>(
                                    curve: Curves.easeInOut,
                                    duration: const Duration(milliseconds: 300),
                                    tween: _tfTween,
                                    builder: (context, fS, _) => TextField(
                                        controller: _controller,
                                        autocorrect: false,
                                        maxLines: 1,
                                        decoration: InputDecoration(
                                            suffixText: temperature.unit),
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        inputFormatters: <TextInputFormatter>[
                                          _TemperatureValueTextInputFormatter()
                                        ],
                                        style: TextStyle(
                                            fontSize: fS,
                                            fontWeight: FontWeight.w500),
                                        onChanged: _onTextFieldChanged))))),
                    const Divider(),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding:
                                  const EdgeInsetsDirectional.only(end: 12),
                              child: Text(
                                  // TODO: Localize
                                  "Temperature unit: ",
                                  style: const TextStyle(fontSize: 16))),
                          SizedBox(
                              height: 36,
                              child: ToggleSwitch(
                                  initialLabelIndex: _unitLbl
                                      .indexWhere((u) => u == temperature.unit),
                                  totalSwitches: _unitLbl.length,
                                  labels: _unitLbl,
                                  onToggle: _onUnitToggle))
                        ]),
                    const Divider(),
                    LayoutBuilder(
                        builder: (context, constraints) => Flex(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              direction: constraints.maxWidth >= 720
                                  ? Axis.horizontal
                                  : Axis.vertical,
                              children: <ElevatedButton>[
                                ElevatedButton(
                                    onPressed: () {},
                                    child: Padding(
                                        padding: _actionBtnPadding,
                                        child: Text(
                                            // TODO: Localize
                                            "Save",
                                            style: _actionBtnTxtStyle)),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            AnitempThemeColourHandler(context)
                                                .mspSuccess)),
                                ElevatedButton(
                                    onPressed: () {},
                                    child: Padding(
                                        padding: _actionBtnPadding,
                                        child: Text(
                                            // TODO: Localize
                                            "Discard",
                                            style: _actionBtnTxtStyle)),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            AnitempThemeColourHandler(context)
                                                .mspError))
                              ]
                                  .map((btn) => Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: btn))
                                  .toList(),
                            ))
                  ]))));
}

class _TemperatureValueTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String nVT = newValue.text;

    if (nVT.contains("e") ||
        (nVT.length != 0 && double.tryParse(nVT) == null)) {
      return oldValue;
    }

    List<String> sp = nVT.split(".");
    if (sp[0].length > 3) {
      String first3 = sp[0].substring(0, 3);
      return TextEditingValue(
          text: first3,
          selection: TextSelection(
              baseOffset: first3.length, extentOffset: first3.length));
    } else if (sp.length == 2 && sp.last.length > 1) {
      String txt = "${sp[0]}.${sp[1][0]}";
      return TextEditingValue(
          text: txt,
          selection:
              TextSelection(baseOffset: txt.length, extentOffset: txt.length));
    }

    return newValue;
  }
}
