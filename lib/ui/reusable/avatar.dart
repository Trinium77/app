import 'dart:typed_data';

import 'package:flutter/material.dart';

class AvatarDisplayer extends StatelessWidget {
  final double? radius;
  final double? minRadius;
  final double? maxRadius;
  final Uint8List? _image;

  AvatarDisplayer(Uint8List? image,
      {super.key, this.radius, this.minRadius, this.maxRadius})
      : this._image = image == null ? null : UnmodifiableUint8ListView(image);

  @override
  Widget build(BuildContext context) => CircleAvatar(
      radius: radius,
      maxRadius: maxRadius,
      minRadius: minRadius,
      backgroundColor: _image == null
          ? Theme.of(context).primaryColor.withAlpha(0x88)
          : null,
      child: _image == null ? const Icon(Icons.person, size: 48) : null,
      backgroundImage: _image == null ? null : MemoryImage(_image!));
}
