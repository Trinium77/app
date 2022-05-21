import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:mime/mime.dart';

import 'animal.dart';
import '../archive/archivable.dart';
import '../database/sql/object.dart';

final RegExp _imageRegex = RegExp(r"^image/.+$", dotAll: true);

final GZipCodec _lightGzip = GZipCodec(level: 3, memLevel: 5);

class _UserBase implements Archivable {
  static final Uint8List _dataSection =
      Uint8List.fromList(<int>[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);

  final String name;
  final Animal animal;
  final Uint8List? image;

  _UserBase(this.name, this.animal, Uint8List? image)
      : assert(image == null
            ? true
            : image.lengthInBytes <= 10 * 1000 * 1000 &&
                _imageRegex.hasMatch(lookupMimeType('', headerBytes: image)!)),
        this.image = image == null ? null : UnmodifiableUint8ListView(image);

  @override
  Uint8List toBytes() {
    Map<String, dynamic> jsonData = {
      "name": name,
      "animal": animal.name,
      "image": image
    };

    List<int> b = _lightGzip.encode(utf8.encode(jsonEncode(jsonData)));

    return b is Uint8List ? b : Uint8List.fromList(b);
  }

  @override
  String toString() => <String, String>{
        "name": name,
        "animal": animal.name,
        "image_size": image?.lengthInBytes.toString() ?? "None"
      }.toString();
}

@immutable
@sealed
abstract class User implements _UserBase {
  String get name;
  Animal get animal;
  Uint8List? get image;

  factory User(
      {required String name,
      required Animal animal,
      required Uint8List? image}) = _User;

  factory User.fromByte(Uint8List bytes) {
    Map<String, Object?> decoded =
        jsonDecode(utf8.decode(_lightGzip.decode(bytes)));

    return _User(
        name: decoded["name"]! as String,
        animal: Animal.values.singleWhere(
            (element) => element.name == decoded["animal"]! as String),
        image: decoded["image"] as Uint8List?);
  }

  User updateName(String name);
  User updateAnimal(Animal animal);
  User updateUint8List(Uint8List? image);
}

class _User extends _UserBase implements User {
  _User(
      {required String name, required Animal animal, required Uint8List? image})
      : super(name, animal, image);

  @override
  User updateAnimal(Animal animal) =>
      _User(name: this.name, animal: animal, image: this.image);

  @override
  User updateName(String name) =>
      _User(name: name, animal: this.animal, image: this.image);

  @override
  User updateUint8List(Uint8List? image) =>
      _User(name: this.name, animal: this.animal, image: image);
}

class UserWithId extends _UserBase implements User, SQLIdReference {
  @override
  final int id;

  UserWithId(this.id,
      {required String name, required Animal animal, required Uint8List? image})
      : super(name, animal, image);

  @override
  UserWithId updateAnimal(Animal animal) =>
      UserWithId(this.id, name: this.name, animal: animal, image: this.image);

  @override
  UserWithId updateName(String name) =>
      UserWithId(this.id, name: name, animal: this.animal, image: this.image);

  @override
  UserWithId updateUint8List(Uint8List? image) =>
      UserWithId(this.id, name: this.name, animal: this.animal, image: image);
}
