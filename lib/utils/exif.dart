import 'dart:typed_data';

import 'package:image/image.dart' as img;

const int _gpsAdddress = 0x8825;

Uint8List? removeGPSData(Uint8List? image, {bool unmodifiable = false}) {
  if (image == null) {
    return null;
  }

  img.Image imageObj = img.decodeImage(image)!;

  Map<int, dynamic> exif = imageObj.exif.data;

  if (exif.containsKey(_gpsAdddress)) {
    exif.remove(_gpsAdddress);
  }

  return unmodifiable
      ? UnmodifiableUint8ListView(imageObj.getBytes())
      : imageObj.getBytes();
}
