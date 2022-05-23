import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:pointycastle/digests/sha3.dart';

import '../model/user.dart';
import '../model/record.dart'
    show TemperatureRecordNode, TemperatureRecordNodeIterableExtension;

final Uint8List _magicBytes =
    Uint8List.fromList(<int>[0x96, 0x99, 0x67, 0x97, 0x60]);

const int _metadataCap = 4096;

@immutable
@sealed
class AnitempCodecData {
  final User user;

  AnitempCodecData(this.user);
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
    listDict.add(0);
    ctxb.add(input.user.toBytes());

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
