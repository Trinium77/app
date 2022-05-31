import 'dart:io';
import 'dart:typed_data';

import '../../database/sql/object.dart';
import '../archive/archivable.dart';
import 'temperature.dart' show TemperatureUnitPreference;

final ZLibCodec _zlib = ZLibCodec(level: 4, memLevel: 4);

class _UserSettingBase extends Archivable with JsonBasedArchivable {
  final TemperatureUnitPreference unitPreferece;
  final bool toleranceCondition;

  const _UserSettingBase(this.unitPreferece, this.toleranceCondition);

  @override
  Map<String, dynamic> get jsonData => <String, dynamic>{
        "unit_preference": unitPreferece.name,
        "tolerance_condition": toleranceCondition
      };

  @override
  Uint8List toBytes() {
    List<int> z = _zlib.encode(super.toBytes());

    return z is Uint8List ? z : Uint8List.fromList(z);
  }
}

abstract class UserSetting implements _UserSettingBase {
  TemperatureUnitPreference get unitPreferece;
  bool get toleranceCondition;

  factory UserSetting(
      {required TemperatureUnitPreference unitPreferece,
      required bool toleranceCondition}) = _UserSetting;

  factory UserSetting.defaultSetting() => UserSetting(
      unitPreferece: TemperatureUnitPreference.uses_recorded_unit,
      toleranceCondition: true);

  factory UserSetting.fromBytes(Uint8List bytes) {
    Map<String, dynamic> decoded =
        JsonBasedArchivable.jbaDecoder(_zlib.decode(bytes));

    return _UserSetting(
        unitPreferece: TemperatureUnitPreference.values.singleWhere(
            (element) => element.name == decoded["unit_preference"] as String),
        toleranceCondition: decoded["tolerance_condition"] as bool);
  }

  UserSetting updateUnitPrefernce(TemperatureUnitPreference unitPreferece);
  UserSetting updateToleranceCondition(bool toleranceCondition);
}

class _UserSetting extends _UserSettingBase implements UserSetting {
  _UserSetting(
      {required TemperatureUnitPreference unitPreferece,
      required bool toleranceCondition})
      : super(unitPreferece, toleranceCondition);

  @override
  UserSetting updateToleranceCondition(bool toleranceCondition) => _UserSetting(
      unitPreferece: this.unitPreferece,
      toleranceCondition: toleranceCondition);

  @override
  UserSetting updateUnitPrefernce(TemperatureUnitPreference unitPreferece) =>
      _UserSetting(
          unitPreferece: unitPreferece,
          toleranceCondition: this.toleranceCondition);
}

class UserSettingWithId extends _UserSettingBase
    implements UserSetting, SQLIdReference {
  @override
  final int id;

  UserSettingWithId(this.id,
      {required TemperatureUnitPreference unitPreferece,
      required bool toleranceCondition})
      : super(unitPreferece, toleranceCondition);

  @override
  UserSettingWithId updateToleranceCondition(bool toleranceCondition) =>
      UserSettingWithId(this.id,
          unitPreferece: this.unitPreferece,
          toleranceCondition: toleranceCondition);

  @override
  UserSettingWithId updateUnitPrefernce(
          TemperatureUnitPreference unitPreferece) =>
      UserSettingWithId(this.id,
          unitPreferece: unitPreferece,
          toleranceCondition: this.toleranceCondition);
}
