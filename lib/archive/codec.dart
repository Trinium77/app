import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:anitemp/model/user_setting.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/digests/sha3.dart';

import '../model/user.dart';
import '../model/record.dart'
    show
        ArchivableTemperatureRecordNodeIterable,
        TemperatureRecordNode,
        TemperatureRecordNodeIterableExtension;

class _AnitempMetadataMap extends MapBase<String, Object> {
  final Map<String, Object> _source;

  _AnitempMetadataMap([Map<String, Object>? source])
      : this._source = source ?? <String, Object>{};

  @override
  Object operator [](Object? key) => _source[key]!;

  @override
  void operator []=(String key, Object value) {
    if (value is Map) {
      throw TypeError();
    }

    _source[key] = value;
  }

  @override
  void clear() {
    _source.clear();
  }

  @override
  Iterable<String> get keys => _source.keys;

  @override
  Object remove(Object? key) => _source.remove(key)!;
}

typedef _Serializer = Uint8List Function();

final Uint8List _magicBytes =
    Uint8List.fromList(<int>[0x96, 0x99, 0x67, 0x97, 0x60]);

const int _metadataCap = 4096;

Uint8List _calcHash(Uint8List context) {
  final SHA3Digest sha3 = SHA3Digest(512);
  return sha3.process(context);
}

class NotAnitempFormatException extends FormatException {
  NotAnitempFormatException._(Uint8List magicBytes)
      : assert(!const ListEquality().equals(magicBytes, _magicBytes)),
        super("This format is not uses for Anitemp data archive", magicBytes);
}

class NotAnitempFileException extends FileSystemException
    implements NotAnitempFormatException {
  final File _file;

  NotAnitempFileException._(this._file);

  @override
  String get message =>
      "File '${_file.absolute.path}' is not a valid Anitemp data archive file.";

  @override
  int? get offset => null;

  @override
  get source => _file.readAsBytesSync().sublist(0, _magicBytes.length);
}

@immutable
@sealed
class AnitempCodecData {
  final User user;
  final Iterable<TemperatureRecordNode> _records;
  final UserSetting userSetting;

  AnitempCodecData(this.user, this._records, this.userSetting);

  ArchivableTemperatureRecordNodeIterable get records =>
      _records.toArchivable();
}

@sealed
class AnitempCodec extends Codec<AnitempCodecData, Uint8List> {
  const AnitempCodec();

  @override
  AnitempDecoder get decoder => const AnitempDecoder._();

  @override
  AnitempEncoder get encoder => const AnitempEncoder._();
}

@sealed
class AnitempDecoder extends Converter<Uint8List, AnitempCodecData> {
  const AnitempDecoder._();

  @override
  AnitempCodecData convert(Uint8List input) {
    final Uint8List mb = input.sublist(0, _magicBytes.length);

    if (!const ListEquality().equals(mb, _magicBytes)) {
      throw NotAnitempFormatException._(mb);
    }

    BytesBuilder dictReader = BytesBuilder();
    final Uint8List dictHashCtx = input.sublist(_magicBytes.length);

    throw UnimplementedError();
  }
}

@sealed
class AnitempEncoder extends Converter<AnitempCodecData, Uint8List> {
  const AnitempEncoder._();

  @override
  Uint8List convert(AnitempCodecData input) {
    _AnitempMetadataMap posDict =
        _AnitempMetadataMap(<String, Object>{"metadata_cap": _metadataCap});

    List<int> listDict =
        <int>[]; // Indicate index of start section (does not included metadata)

    BytesBuilder ctxb = BytesBuilder();
    Iterable<_Serializer> addOrder = <_Serializer>[
      input.user.toBytes,
      input.records.toBytes,
      input.userSetting.toBytes
    ];

    for (_Serializer s in addOrder) {
      listDict.add(ctxb.length);
      ctxb.add(s());
    }

    Uint8List ctxl = ctxb.toBytes();
    Uint8List ctxHash = _calcHash(ctxl);

    posDict["hash_length"] = ctxHash.length;
    posDict["context_pos"] = listDict;

    BytesBuilder pack = BytesBuilder()
      ..add(_magicBytes)
      ..add(utf8.encode(jsonEncode(posDict)))
      ..add(ctxHash)
      ..add(ctxl);

    return pack.toBytes();
  }
}
