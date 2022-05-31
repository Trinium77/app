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
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) => AlertDialog(
                      title: Text("Error"),
                      content: Text("Saving user data unsucessfully."),
                      actions: <TextButton>[
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Close")),
                        if (kDebugMode)
                          TextButton(
                              onPressed: () {
                                print(e);
                              },
                              child: Text("Print to console"))
                      ]));
        } finally {
          if (p.isOpen()) {
            p.close();
          }
        }

        return !failed;
      },
      child: Scaffold());
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
