import 'dart:io';
import 'dart:typed_data';

import 'package:meta/meta.dart';
import 'package:mime/mime.dart';

import '../archive/archivable.dart';
import '../database/sql/object.dart';
import '../utils/exif.dart' as exifutil;
import 'animal.dart';

/// [RegExp] uses for checking image MIME type
final RegExp _imageRegex = RegExp(r"^image/.+$", dotAll: true);

/// Configuration of [GZipCodec] for fast-compressing [User] data.
final GZipCodec _lightGzip = GZipCodec(level: 3, memLevel: 5);

/// Based class of [User] with [Archivable] implementation.
class _UserBase extends Archivable with JsonBasedArchivable {
  final String name;
  final Animal animal;
  final Uint8List? image;

  _UserBase(this.name, this.animal, Uint8List? image)
      : assert(image == null
            ? true
            : image.lengthInBytes <= 10 * 1000 * 1000 &&
                _imageRegex.hasMatch(lookupMimeType('', headerBytes: image)!)),
        this.image = exifutil.removeGPSData(image, unmodifiable: true);

  @override
  Uint8List toBytes() {
    List<int> b = _lightGzip.encode(super.toBytes());

    return b is Uint8List ? b : Uint8List.fromList(b);
  }

  @override
  String toString() => <String, String>{
        "name": name,
        "animal": animal.name,
        "image_size": image?.lengthInBytes.toString() ?? "None"
      }.toString();

  @override
  Map<String, dynamic> get jsonData =>
      <String, dynamic>{"name": name, "animal": animal.name, "image": image};
}

/// An entity to identify the relationship of data.
@immutable
@sealed
abstract class User implements _UserBase {
  /// Name of the [User].
  String get name;

  /// [Animal] type of this [User].
  Animal get animal;

  /// Image of the [User] in [Uint8List], if provided.
  Uint8List? get image;

  /// Construct a new [User] information.
  factory User(
      {required String name,
      required Animal animal,
      required Uint8List? image}) = _User;

  /// Decode [User] information from [bytes].
  factory User.fromByte(Uint8List bytes) {
    Map<String, dynamic> decoded =
        JsonBasedArchivable.jbaDecoder(_lightGzip.decode(bytes));

    return _User(
        name: decoded["name"] as String,
        animal: Animal.values.singleWhere(
            (element) => element.name == decoded["animal"] as String),
        image: decoded["image"] as Uint8List?);
  }

  /// Create a new [User] with applied [name].
  User updateName(String name);

  /// Create a new [User] with applied [animal] type.
  User updateAnimal(Animal animal);

  /// Create a new [User] with applied [image].
  User updateImage(Uint8List? image);
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
  User updateImage(Uint8List? image) =>
      _User(name: this.name, animal: this.animal, image: image);
}

/// Subtype of [User] which fetch from database.
class UserWithId extends _UserBase implements User, SQLIdReference {
  /// [id] of SQL's tuple.
  @override
  final int id;

  /// Construct new [User] from SQL.
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
  UserWithId updateImage(Uint8List? image) =>
      UserWithId(this.id, name: this.name, animal: this.animal, image: image);
}
