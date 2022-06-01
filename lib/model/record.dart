import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:meta/meta.dart';

import '../archive/archivable.dart';
import '../database/sql/object.dart';
import '../model/temperature.dart';

/// Standarise CSV format [Codec].
final CsvCodec _csvCodec = CsvCodec(eol: "\n", shouldParseNumbers: false);

/// Base object of [TemperatureRecordNode].
class _TemperatureRecordNodeBase {
  final CommonTemperature temperature;
  final DateTime recordedAt;

  _TemperatureRecordNodeBase(this.temperature, DateTime recordedAt)
      : this.recordedAt = recordedAt.toUtc();

  @override
  String toString() => "(${recordedAt.toIso8601String()}) Temp: $temperature";
}

/// An object contains recorded [Temperature] in specified [DateTime]
@immutable
@sealed
abstract class TemperatureRecordNode implements _TemperatureRecordNodeBase {
  /// A [temperature] when this node created.
  ///
  /// Note: Only accept [CommonTemperature] only.
  @override
  CommonTemperature get temperature;

  /// When this node created.
  @override
  DateTime get recordedAt;

  /// Construct a new [TemperatureRecordNode].
  factory TemperatureRecordNode(
      {required CommonTemperature temperature,
      required DateTime recordedAt}) = _TemperatureRecordNode;

  /// Update [temperature] of this node data.
  TemperatureRecordNode updateTemperature(CommonTemperature temperature);

  /// Update when it recorded.
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

/// A [TemperatureRecordNode] from database.
class TemperatureRecordNodeWithId extends _TemperatureRecordNodeBase
    implements TemperatureRecordNode, SQLIdReference {
  @override
  final int id;

  /// Construct [TemperatureRecordNodeWithId].
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

/// Add advance feature in [Iterable] of [TemperatureRecordNode].
extension TemperatureRecordNodeIterableExtension<
    N extends TemperatureRecordNode> on Iterable<N> {
  /// Find a range of [DateTime] when [TemperatureRecordNode] recorded.
  ///
  /// [from] and [to] can not be [Null] at the same time.
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

  /// Convert [Iterable] of [TemperatureRecordNode] to 2D [List] of [String]
  /// to repersent CSV in Dart object.
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

  /// Parse this [Iterable] to **unmodifiable**
  /// [ArchivableTemperatureRecordNodeIterable] for handing [Archivable]
  /// features.
  ArchivableTemperatureRecordNodeIterable toArchivable() =>
      ArchivableTemperatureRecordNodeIterable(this, growable: false);

  /// Parse [csv] to a [List] of [TemperatureRecordNode].
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

/// [List] exclusive feature of [TemperatureRecordNode].
extension TemperatureRecordNodeListExtension<N extends TemperatureRecordNode>
    on List<N> {
  int _sortInternal<C extends Comparable>(bool reverse, C a, C b) {
    int c = b.compareTo(a);

    if (reverse) {
      c *= -1;
    }

    return c;
  }

  /// Sort this list by [TemperatureRecordNode.temperature].
  ///
  /// By default, the order is descended. If want to sort as ascending order,
  /// apply [ascend] to `true`.
  void sortByTemperature({bool ascend = false}) => sort((a, b) =>
      _sortInternal<Temperature>(ascend, a.temperature, b.temperature));

  /// Sort this list by [TemperatureRecordNode.recordedAt].
  ///
  /// By default, newer [DateTime] will be sorted first. If sort by the oldest,
  /// please apply [oldToNew] to `true`.
  void sortByRecordedAt({bool oldToNew = false}) => sort(
      (a, b) => _sortInternal<DateTime>(oldToNew, a.recordedAt, b.recordedAt));
}

/// [Iterable] of [TemperatureRecordNode] with [Archivable] feature to export
/// [Uint8List].
class ArchivableTemperatureRecordNodeIterable extends Archivable
    with IterableMixin<TemperatureRecordNode> {
  final Iterable<TemperatureRecordNode> _source;

  /// Construct [ArchivableTemperatureRecordNodeIterable] with existed [source].
  ArchivableTemperatureRecordNodeIterable(
      Iterable<TemperatureRecordNode> source,
      {bool growable = true})
      : this._source = List.from(source, growable: growable);

  /// Parse [ArchivableTemperatureRecordNodeIterable] from [bytes].
  factory ArchivableTemperatureRecordNodeIterable.fromBytes(Uint8List bytes) {
    List<List<String>> csv =
        _csvCodec.decoder.convert<String>(utf8.decode(bytes));

    return ArchivableTemperatureRecordNodeIterable(
        TemperatureRecordNodeIterableExtension.parseFromCsv(csv));
  }

  @override
  Iterator<TemperatureRecordNode> get iterator => _source.iterator;

  @override
  Uint8List toBytes() {
    List<int> encoded = utf8.encode(_csvCodec.encoder.convert(toCsv()));

    return encoded is Uint8List ? encoded : Uint8List.fromList(encoded);
  }
}
