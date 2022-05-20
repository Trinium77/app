import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../model/user.dart';

final Uint8List _magicBytes =
    Uint8List.fromList(<int>[0x96, 0x99, 0x67, 0x97, 0x06]);

@immutable
@sealed
class AnitempCodedData {
  final User user;

  AnitempCodedData(this.user);
}

@sealed
class AnitempCodec extends Codec<AnitempCodedData, Uint8List> {
  const AnitempCodec();

  @override
  AnitempDecoder get decoder => const AnitempDecoder._();

  @override
  AnitempEncoder get encoder => const AnitempEncoder._();
}

@sealed
class AnitempDecoder extends Converter<Uint8List, AnitempCodedData> {
  const AnitempDecoder._();

  @override
  AnitempCodedData convert(Uint8List input) {
    // TODO: implement convert
    throw UnimplementedError();
  }
}

@sealed
class AnitempEncoder extends Converter<AnitempCodedData, Uint8List> {
  const AnitempEncoder._();

  @override
  Uint8List convert(AnitempCodedData input) {
    BytesBuilder builder = BytesBuilder()
      ..add(_magicBytes)
      ..add(input.user.toBytes());

    return builder.toBytes();
  }
}
