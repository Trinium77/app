import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:mime/mime.dart';

import 'animal.dart';
import '../archive/archivable.dart';

final RegExp _imageRegex = RegExp(r"^image/.+$", dotAll: true);

abstract class _UserBase implements Archivable {
  String get name;
  Animal get animal;
  Uint8List? get image;

  @override
  Uint8List toBytes() {
    // TODO: implement toBytes
    throw UnimplementedError();
  }
}

@immutable
@sealed
abstract class User extends _UserBase {
  factory User(
      {required String name,
      required Animal animal,
      required Uint8List? image}) = _User;

  User updateName(String name);
  User updateAnimal(Animal animal);
  User updateUint8List(Uint8List? image);
}

class _User extends _UserBase implements User {
  @override
  final String name;

  @override
  final Animal animal;

  @override
  final Uint8List? image;

  _User({required this.name, required this.animal, required Uint8List? image})
      : assert(image == null
            ? true
            : _imageRegex.hasMatch(lookupMimeType('', headerBytes: image)!)),
        this.image = image == null ? null : UnmodifiableUint8ListView(image);

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

  @override
  final String name;

  @override
  final Animal animal;

  @override
  final Uint8List? image;

  UserWithId(this.id,
      {required this.name, required this.animal, required Uint8List? image})
      : assert(image == null
            ? true
            : _imageRegex.hasMatch(lookupMimeType('', headerBytes: image)!)),
        this.image = image == null ? null : UnmodifiableUint8ListView(image);

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
