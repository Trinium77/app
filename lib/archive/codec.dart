import 'dart:convert';
import 'dart:typed_data';

import 'package:anitemp/model/user_setting.dart';
import 'package:meta/meta.dart';
import 'package:pointycastle/digests/sha3.dart';

import '../model/user.dart';
import '../model/record.dart'
    show
        ArchivableTemperatureRecordNodeIterable,
        TemperatureRecordNode,
        TemperatureRecordNodeIterableExtension;

typedef _Serializer = Uint8List Function();

final Uint8List _magicBytes =
    Uint8List.fromList(<int>[0x96, 0x99, 0x67, 0x97, 0x60]);

const int _metadataCap = 4096;

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
    // TODO: implement convert
    throw UnimplementedError();
  }
}

@sealed
class AnitempEncoder extends Converter<AnitempCodecData, Uint8List> {
  const AnitempEncoder._();

  @override
  Uint8List convert(AnitempCodecData input) {
    Map<String, dynamic> posDict = <String, dynamic>{
      "metadata_cap": _metadataCap
    };

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
    final SHA3Digest sha3 = SHA3Digest(512);
    Uint8List ctxHash = sha3.process(ctxl);

    posDict["hash_length"] = ctxHash.length;
    posDict["context_pos"] = listDict;

    BytesBuilder pack = BytesBuilder()
      ..add(_magicBytes)
      ..add(utf8.encode(jsonEncode(posDict)));

    int fillLength = _metadataCap - pack.length;
    pack
      ..add(List.filled(fillLength - ctxHash.length, 0))
      ..add(ctxHash);

    pack.add(ctxl);

    return pack.toBytes();
  }
}
