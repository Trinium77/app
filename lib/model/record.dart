import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../database/sql/object.dart';
import '../model/temperature.dart';

class _TemperatureRecordNodeBase {
  final CommonTemperature temperature;
  final DateTime recordedAt;

  _TemperatureRecordNodeBase(this.temperature, DateTime recordedAt)
      : this.recordedAt = recordedAt.toUtc();
}

@immutable
@sealed
abstract class TemperatureRecordNode implements _TemperatureRecordNodeBase {
  @override
  CommonTemperature get temperature;

  @override
  DateTime get recordedAt;

  factory TemperatureRecordNode(
      {required CommonTemperature temperature,
      required DateTime recordedAt}) = _TemperatureRecordNode;

  TemperatureRecordNode updateTemperature(CommonTemperature temperature);

  TemperatureRecordNode updateRecordedAt(DateTime recordedAt);
}

class _TemperatureRecordNode extends _TemperatureRecordNodeBase
    implements TemperatureRecordNode {
  _TemperatureRecordNode(
      {required CommonTemperature temperature, required DateTime recordedAt})
      : super(temperature, recordedAt);

  @override
  TemperatureRecordNode updateRecordedAt(DateTime recordedAt) =>
      _TemperatureRecordNode(
          temperature: this.temperature, recordedAt: recordedAt);

  @override
  TemperatureRecordNode updateTemperature(CommonTemperature temperature) =>
      _TemperatureRecordNode(
          temperature: temperature, recordedAt: this.recordedAt);
}

class TemperatureRecordNodeWithId extends _TemperatureRecordNodeBase
    implements TemperatureRecordNode, SQLIdReference {
  @override
  final int id;

  TemperatureRecordNodeWithId(this.id,
      {required CommonTemperature temperature, required DateTime recordedAt})
      : super(temperature, recordedAt);

  @override
  TemperatureRecordNodeWithId updateRecordedAt(DateTime recordedAt) =>
      TemperatureRecordNodeWithId(this.id,
          temperature: this.temperature, recordedAt: recordedAt);

  @override
  TemperatureRecordNodeWithId updateTemperature(
          CommonTemperature temperature) =>
      TemperatureRecordNodeWithId(this.id,
          temperature: temperature, recordedAt: this.recordedAt);
}

extension TemperatureRecordNodeIterableExtension<
    N extends TemperatureRecordNode> on Iterable<N> {
  Iterable<N> whereRecordedAt({DateTime? from, DateTime? to}) {
    DateTime? utcf = from?.toUtc(), utct = to?.toUtc();

    if (utcf == null && utct == null) {
      throw ArgumentError(
          "Both parameter can not be nulled at the same time.", "from, to");
    } else if (utcf != null && utct != null && utcf.isAfter(utct)) {
      throw ArgumentError.value(
          from, "from", "Reversed date time range is forbidden.");
    }

    return where((nodes) =>
        !(utcf?.isBefore(nodes.recordedAt) ?? false) &&
        !(utct?.isAfter(nodes.recordedAt) ?? false));
  }

  List<List<String>> toCsv() {
    List<List<String>> csv = <List<String>>[
      List.unmodifiable(<String>["recordedAt", "temp", "unit"])
    ];

    for (N n in this) {
      csv.add(UnmodifiableListView(<String>[
        n.recordedAt.toIso8601String(),
        n.temperature.value.toString(),
        n.temperature.unit
      ]));
    }

    return UnmodifiableListView(csv);
  }

  static List<TemperatureRecordNode> parseFromCsv(List<List<String>> csv) {
    List<TemperatureRecordNode> parsed = <TemperatureRecordNode>[];

    for (int idx = 1; idx < csv.length; idx++) {
      parsed.add(_TemperatureRecordNode(
          temperature:
              Temperature.parseSperated(double.parse(csv[idx][1]), csv[idx][2]),
          recordedAt: DateTime.parse(csv[idx][0])));
    }

    return parsed;
  }
}

extension TemperatureRecordNodeListExtension<N extends TemperatureRecordNode>
    on List<N> {
  int _sortInternal<C extends Comparable>(bool reverse, C a, C b) {
    int c = b.compareTo(a);

    if (reverse) {
      c *= -1;
    }

    return c;
  }

  void sortByTemperature({bool ascend = false}) => sort((a, b) =>
      _sortInternal<Temperature>(ascend, a.temperature, b.temperature));

  void sortByRecordedAt({bool oldToNew = false}) => sort(
      (a, b) => _sortInternal<DateTime>(oldToNew, a.recordedAt, b.recordedAt));
}
