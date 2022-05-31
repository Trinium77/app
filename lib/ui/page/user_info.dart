import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, kDebugMode;
import 'package:flutter/material.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../database/sql/typebind/user.dart';
import '../../database/sql/typebind/user_setting.dart'
    show UserSettingSQLExtension;
import '../../model/animal.dart';
import '../../model/user.dart';
import '../../model/user_setting.dart';
import '../reusable/error_dialog.dart';
import '../reusable/transperant_appbar.dart';
import '../reusable/user_widget.dart';

abstract class AbstractedUserPage extends StatefulWidget {
  const AbstractedUserPage({super.key});

  @override
  State<AbstractedUserPage> createState();
}

abstract class _AbstractedUserPageState<U extends User,
    A extends AbstractedUserPage> extends State<A> {
  late final TextEditingController _nameController;
  late Animal _animal;
  late Uint8List? _image;
  late bool _requestSave;

  U get _usrObj;

  Future<void> onSubmit();

  @override
  void initState() {
    _requestSave = false;
    super.initState();
    _nameController = TextEditingController();
  }

  Future<bool> _confirmDiscard(BuildContext context) async =>
      await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: Text(
                    // TODO: Localize
                    "Discard changes"),
                content: Text(
                    // TODO: Localize
                    "Do you want to leave this page? Current user data will not be applied."),
                actions: <TextButton>[
                  TextButton(
                      onPressed: () => Navigator.pop<bool>(context, true),
                      child: Text(
                          // TODO: Localize
                          "Yes")),
                  TextButton(
                      onPressed: () => Navigator.pop<bool>(context, false),
                      child: Text(
                          // TODO: Localize
                          "No"))
                ],
              )) ??
      false;

  CircleAvatar _avatar(BuildContext context) {
    const double rad = 75;
    return _image == null
        ? CircleAvatar(
            radius: rad,
            backgroundColor: Theme.of(context).primaryColor.withAlpha(0x88),
            child: const Icon(Icons.person, size: 48))
        : CircleAvatar(
            radius: rad,
            backgroundImage: MemoryImage(_image!),
          );
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async {
        if (!_requestSave) {
          return await _confirmDiscard(context);
        }

        bool failed = false;

        final ProgressDialog p = ProgressDialog(context: context);
        p.show(max: 1, msg: "Save user setting...");

        try {
          await onSubmit().then((_) => p.update(value: 1));
        } catch (e) {
          failed = true;
          showErrorDialog(
              context,
              e,
              // TODO: Localize
              "Saving user data unsuccessfully");
        } finally {
          if (p.isOpen()) {
            p.close();
          }
        }

        return !failed;
      },
      child: SafeArea(
          child: Scaffold(
        appBar: TransperantAppBar.unifyIconTheme(context),
        body: ListView(
            padding: const EdgeInsets.all(12),
            shrinkWrap: true,
            children: <Widget>[
              GestureDetector(
                child: _avatar(context),
              )
            ]),
      )));
}

class NewUserPage extends AbstractedUserPage {
  const NewUserPage({super.key});

  @override
  State<NewUserPage> createState() => _NewUserPageState();
}

class _NewUserPageState extends _AbstractedUserPageState<User, NewUserPage> {
  @override
  void initState() {
    _animal = Animal.human;
    _image = null;
    super.initState();
  }

  @override
  User get _usrObj =>
      User(name: _nameController.text, animal: _animal, image: _image);

  @override
  Future<void> onSubmit() async {
    await _usrObj.insertUserToDb(keepOpen: true);
    await UserSetting.defaultSetting().insertSettingToUser();
  }
}

class ExistedUserPage extends AbstractedUserPage with UserWidget<UserWithId> {
  @override
  final UserWithId user;

  ExistedUserPage(this.user, {super.key});

  @override
  State<ExistedUserPage> createState() => _ExistedUserPageState();
}

class _ExistedUserPageState
    extends _AbstractedUserPageState<UserWithId, ExistedUserPage> {
  @override
  void initState() {
    _animal = widget.user.animal;
    _image = widget.user.image;
    super.initState();
    _nameController.text = widget.user.name;
  }

  @override
  UserWithId get _usrObj => widget.user
      .updateName(_nameController.text)
      .updateAnimal(_animal)
      .updateImage(_image);

  @override
  Future<void> onSubmit() async {
    await _usrObj.updateUserIdData();
  }
}
