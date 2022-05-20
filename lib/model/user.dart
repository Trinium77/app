import 'dart:convert';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:mime/mime.dart';

import 'animal.dart';
import '../archive/archivable.dart';

final RegExp _imageRegex = RegExp(r"^image/.+$", dotAll: true);

abstract class _UserBase implements Archivable {
  static final Uint8List _dataSection =
      Uint8List.fromList(<int>[0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);

  final String name;
  final Animal animal;
  final Uint8List? image;

  _UserBase(this.name, this.animal, Uint8List? image)
      : assert(image == null
            ? true
            : _imageRegex.hasMatch(lookupMimeType('', headerBytes: image)!)),
        this.image = image == null ? null : UnmodifiableUint8ListView(image);

  @override
  Uint8List toBytes() {
    BytesBuilder bb = BytesBuilder()
      ..add(_dataSection)
      ..add(utf8.encode(name))
      ..add(_dataSection)
      ..add(utf8.encode(animal.name))
      ..add(_dataSection);

    if (image != null) {
      bb
        ..add(image!)
        ..add(_dataSection);
    }

    return bb.toBytes();
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
abstract class User extends _UserBase {
  String get name;
  Animal get animal;
  Uint8List? get image;

  factory User(
      {required String name,
      required Animal animal,
      required Uint8List? image}) = _User;

  factory User.fromByte(Uint8List bytes) {
    List<Uint8List> section = [];
    List<int> content = [];
    List<int> nulbuf = [];

    for (int b in bytes) {
      if (b == 0x00) {
        nulbuf.add(b);
      }

      if (nulbuf.length == _UserBase._dataSection.length) {
        if (content.isNotEmpty) {
          section.add(Uint8List.fromList(content));
        }
        content.clear();
        nulbuf.clear();
      } else if (b != 0x00) {
        if (nulbuf.isNotEmpty) {
          content.addAll(nulbuf);
          nulbuf.clear();
        }
        content.add(b);
      }
    }

    String name = utf8.decode(section[0]);
    Animal animal =
        Animal.values.singleWhere((a) => a.name == utf8.decode(section[1]));
    Uint8List? image = section.length >= 3 ? section[2] : null;

    return _User(name: name, animal: animal, image: image);
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

class UserWithId extends _UserBase implements User {
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
