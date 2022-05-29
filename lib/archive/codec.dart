import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:lzma/lzma.dart' show lzma;
import 'package:meta/meta.dart';
import 'package:pointycastle/digests/sha3.dart';

import '../model/record.dart'
    show
        ArchivableTemperatureRecordNodeIterable,
        TemperatureRecordNode,
        TemperatureRecordNodeIterableExtension;
import '../model/user.dart';
import '../model/user_setting.dart';
import 'archivable.dart';

class _KeyUnexistedError extends ArgumentError {
  final Object? _key;

  _KeyUnexistedError(this._key)
      : assert(_key is String),
        super();

  @override
  get message => "No $_key found in this map.";
}

class _AnitempMetadataMap extends MapBase<String, Object> {
  final Map<String, Object> _source;

  _AnitempMetadataMap([Map<String, Object>? source])
      : this._source = source ?? <String, Object>{};

  @override
  Object operator [](Object? key) {
    if (!_source.containsKey(key)) {
      throw _KeyUnexistedError(key);
    }

    return _source[key]!;
  }

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
typedef _Parser = Archivable Function(Uint8List);

final Uint8List _magicBytes =
    Uint8List.fromList(<int>[0x96, 0x99, 0x67, 0x97, 0x60]);

int get magicBytesLength => _magicBytes.length;

Uint8List _calcHash(Uint8List context) {
  final SHA3Digest sha3 = SHA3Digest(512);
  return sha3.process(context);
}

@sealed
class NotAnitempFormatException extends FormatException {
  NotAnitempFormatException._(Uint8List magicBytes)
      : assert(!const ListEquality().equals(magicBytes, _magicBytes)),
        super("This format is not uses for Anitemp data archive", magicBytes);
}

/// An object as agent role to convert between [Uint8List] and Anitemp data
/// objects.
@immutable
@sealed
class AnitempCodecData {
  /// [User] data.
  final User user;
  final Iterable<TemperatureRecordNode> _records;

  /// Setting preference of current [user].
  final UserSetting userSetting;

  /// Construct [AnitempCodecData] from object.
  AnitempCodecData(this.user, this._records, this.userSetting);

  factory AnitempCodecData._resolve(List<int> dict, Uint8List context) {
    final List<_Parser> aFactory = <_Parser>[
      User.fromByte,
      ArchivableTemperatureRecordNodeIterable.fromBytes,
      UserSetting.fromBytes
    ];

    final List<Archivable?> parsed = <Archivable>[];

    for (int fidx = 0; fidx < aFactory.length || fidx < dict.length; fidx++) {
      Uint8List ctxASec;

      try {
        ctxASec = context.sublist(dict[fidx], dict[fidx + 1]);
      } on RangeError {
        // When reached last dict
        ctxASec = context.sublist(dict[fidx]);
      }

      parsed.add(aFactory[fidx](ctxASec));
    }

    if (aFactory.length > dict.length) {
      // Fill null for applyng default setting that ensure backward compatable.
      parsed.addAll(
          List.generate(aFactory.length - dict.length, (index) => null));
    }

    return AnitempCodecData(parsed[0] as User,
        parsed[1] as Iterable<TemperatureRecordNode>, parsed[2] as UserSetting);
  }

  /// Get [user]'s recorded data.
  ArchivableTemperatureRecordNodeIterable get records =>
      _records.toArchivable();
}

/// [Codec] uses convert between [AnitempCodecData] and [Uint8List].
///
/// If data encoded with [lzma], please uses [ComprassedAnitempCodec].
@sealed
class AnitempCodec extends Codec<AnitempCodecData, Uint8List> {
  /// Construct new [AnitempCodec].
  const AnitempCodec();

  @override
  AnitempDecoder get decoder => const AnitempDecoder._();

  @override
  AnitempEncoder get encoder => const AnitempEncoder._();
}

/// Decode [Uint8List] to [AnitempCodecData].
@sealed
class AnitempDecoder extends Converter<Uint8List, AnitempCodecData> {
  const AnitempDecoder._();

  @override
  AnitempCodecData convert(Uint8List input) {
    final Uint8List mb = input.sublist(0, _magicBytes.length);

    if (!const ListEquality().equals(mb, _magicBytes)) {
      throw NotAnitempFormatException._(mb);
    }

    final List<int> metadataJsonByte = input
        .sublist(input.firstWhere((element) => element == 123),
            input.firstWhere((element) => element == 125))
        .toList(growable: false);

    final Map<String, dynamic> metadataJson =
        jsonDecode(ascii.decode(metadataJsonByte));

    final List<int> dict = metadataJson["context_pos"];
    final int hashLength = metadataJson["hash_length"];

    final int ctxStart =
        _magicBytes.length + metadataJsonByte.length + hashLength;

    final Uint8List providedHash = Uint8List.fromList(
        input.sublist(ctxStart - hashLength, ctxStart).toList());

    final Uint8List context = input.sublist(ctxStart);

    assert(const ListEquality().equals(providedHash, _calcHash(context)),
        "Data context contains invalid modification.");

    return AnitempCodecData._resolve(dict, context);
  }
}

/// Encode [AnitempCodecData] to [Uint8List].
@sealed
class AnitempEncoder extends Converter<AnitempCodecData, Uint8List> {
  const AnitempEncoder._();

  @override
  Uint8List convert(AnitempCodecData input) {
    _AnitempMetadataMap posDict = _AnitempMetadataMap(<String, Object>{});

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
      ..add(ascii.encode(jsonEncode(posDict)))
      ..add(ctxHash)
      ..add(ctxl);

    return pack.toBytes();
  }
}

/// An [AnitempCodec] with [lzma] compression.
class CompressedAnitempCodec extends AnitempCodec {
  /// Construct [CompressedAnitempCodec].
  const CompressedAnitempCodec();

  @override
  AnitempEncoder get encoder => const CompressedAnitempEncoder._();

  @override
  AnitempDecoder get decoder => const CompressedAnitempDecoder._();
}

/// Encode compressed [AnitempCodecData] to [Uint8List].
class CompressedAnitempEncoder extends AnitempEncoder {
  const CompressedAnitempEncoder._() : super._();

  @override
  Uint8List convert(AnitempCodecData input) {
    List<int> compressed = lzma.encode(super.convert(input));

    return compressed is Uint8List
        ? compressed
        : Uint8List.fromList(compressed);
  }
}

/// Decode [Uint8List] to [AnitempCodecData] with decompression.
class CompressedAnitempDecoder extends AnitempDecoder {
  const CompressedAnitempDecoder._() : super._();

  @override
  AnitempCodecData convert(Uint8List input) {
    List<int> decompressed = lzma.decode(input);

    return super.convert(decompressed is Uint8List
        ? decompressed
        : Uint8List.fromList(decompressed));
  }
}
