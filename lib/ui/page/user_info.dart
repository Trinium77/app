import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:remove_emoji/remove_emoji.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';

import '../../database/sql/typebind/user.dart';
import '../../database/sql/typebind/user_setting.dart'
    show UserSettingSQLExtension;
import '../../model/animal.dart';
import '../../model/user.dart';
import '../../model/user_setting.dart';
import '../reusable/animal_locales.dart';
import '../reusable/error_dialog.dart';
import '../reusable/action_buttons.dart' show SaveAndDiscardActionButtons;
import '../reusable/transperant_appbar.dart';
import '../reusable/user_widget.dart';

abstract class _ImageSelectionProvider {
  factory _ImageSelectionProvider.gallery() =>
      Platform.isAndroid || Platform.isIOS
          ? _MobileImageSelectionProvider(ImageSource.gallery)
          : _DesktopImageSelectionProvider();

  factory _ImageSelectionProvider.camera() {
    if (Platform.isAndroid || Platform.isIOS) {
      return _MobileImageSelectionProvider(ImageSource.camera);
    }

    throw UnsupportedError("No desktop camera implementation");
  }

  Future<Uint8List?> pickImage();
}

class _DesktopImageSelectionProvider implements _ImageSelectionProvider {
  @override
  Future<Uint8List?> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.image,
        dialogTitle: "Select user image");

    if (result == null) {
      return null;
    }

    assert(result.count == 1);

    return result.files.single.bytes;
  }
}

class _MobileImageSelectionProvider implements _ImageSelectionProvider {
  final ImageSource source;
  final ImagePicker picker;

  _MobileImageSelectionProvider(this.source) : this.picker = ImagePicker();

  @override
  Future<Uint8List?> pickImage() async {
    XFile? result = await picker.pickImage(source: source);

    if (result == null) {
      return null;
    }

    return result.readAsBytes();
  }
}

extension on ImageSource {
  String displayName(BuildContext context) {
    switch (this) {
      case ImageSource.camera:
        return "Take photo";
      case ImageSource.gallery:
        return "Pick from gallery";
    }
  }
}

abstract class AbstractedUserPage extends StatefulWidget {
  const AbstractedUserPage({super.key});

  @override
  State<AbstractedUserPage> createState();
}

enum _ChangeImageOptions { select, remove }

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

  void _onChangeImage(BuildContext context) async {
    _ImageSelectionProvider isp;

    if (Platform.isAndroid || Platform.isIOS) {
      ImageSource? src = await showDialog<ImageSource>(
          context: context,
          builder: (context) => SimpleDialog(
              title: Text("Get image sources"),
              children: ImageSource.values
                  .map((e) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, e),
                      child: Text(e.displayName(context))))
                  .toList()));

      if (src == null) {
        return;
      }

      isp = _MobileImageSelectionProvider(src);
    } else {
      isp = _DesktopImageSelectionProvider();
    }

    Uint8List? result = await isp.pickImage();

    if (result != null) {
      setState(() {
        _image = result;
      });
    }
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
            child: const FittedBox(child: Icon(Icons.person)))
        : CircleAvatar(
            radius: rad,
            backgroundImage: MemoryImage(_image!),
          );
  }

  void _longPressAvaterAction(BuildContext context) async {
    _ChangeImageOptions? opts = await showDialog<_ChangeImageOptions>(
        context: context,
        builder: (context) => SimpleDialog(children: <SimpleDialogOption>[
              SimpleDialogOption(
                  onPressed: () => Navigator.pop<_ChangeImageOptions>(
                      context, _ChangeImageOptions.select),
                  child: Text(
                      // TODO: Localize
                      "Select new user image")),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop<_ChangeImageOptions>(
                      context, _ChangeImageOptions.remove),
                  child: Text(
                      // TODO: Localize
                      "Reset user image to default"))
            ]));

    if (opts != null) {
      switch (opts) {
        case _ChangeImageOptions.select:
          _onChangeImage(context);
          break;
        case _ChangeImageOptions.remove:
          setState(() {
            _image = null;
          });
          break;
      }
    }
  }

  Future<bool> _popProcess(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () => _popProcess(context),
      child: SafeArea(
          child: Scaffold(
              appBar: TransperantAppBar.unifyIconTheme(context),
              body: ListView(
                  padding: const EdgeInsets.all(12),
                  shrinkWrap: true,
                  children: <Widget>[
                    GestureDetector(
                      child: _avatar(context),
                      onTap: () => _onChangeImage(context),
                      onLongPress: () => _longPressAvaterAction(context),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),
                    TextField(
                        controller: _nameController,
                        autocorrect: false,
                        inputFormatters: <TextInputFormatter>[
                          _NameTextInputFormatter()
                        ],
                        maxLines: 1,
                        maxLength: 80,
                        decoration: InputDecoration(
                            labelText:
                                // TODO: Localize
                                "Name")),
                    ListTile(
                        title: Text(
                            // TODO: Localize
                            "Animal"),
                        trailing: DropdownButton<Animal>(
                            value: _animal,
                            items: Animal.values
                                .map<DropdownMenuItem<Animal>>((e) =>
                                    DropdownMenuItem(
                                        value: e,
                                        child: Text(e.displayName(context))))
                                .toList(),
                            onChanged: (newVal) {
                              if (newVal != null) {
                                setState(() {
                                  _animal = newVal;
                                });
                              }
                            })),
                    const Divider(),
                    SaveAndDiscardActionButtons(onSave: () {
                      setState(() {
                        _requestSave = true;
                      });
                      Navigator.pop<bool>(context, true);
                    }, onDiscard: () {
                      Navigator.pop<bool>(context, false);
                    })
                  ]))));
}

class _NameTextInputFormatter extends TextInputFormatter {
  final RemoveEmoji _removeEmoji;

  _NameTextInputFormatter() : this._removeEmoji = RemoveEmoji();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String nt = _removeEmoji
        .removemoji(newValue.text)
        .replaceAll(RegExp(r"\p{Private_Use}", unicode: true), "");

    return TextEditingValue(
        text: nt,
        selection:
            TextSelection(baseOffset: nt.length, extentOffset: nt.length));
  }
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
