import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';

class CloseConfirmScaffold extends StatefulWidget {
  final Scaffold _scaffold;

  const CloseConfirmScaffold({required Scaffold scaffold, super.key})
      : this._scaffold = scaffold;

  @override
  State<CloseConfirmScaffold> createState() =>
      Platform.isLinux || Platform.isMacOS || Platform.isWindows
          ? _CloseConfirmScaffoldDesktopState()
          : _CloseConfirmScaffoldPortableState();
}

abstract class _CloseConfirmScaffoldBaseState
    extends State<CloseConfirmScaffold> {
  Future<bool> requestClose() async =>
      await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                  title: Text(
                      // TODO: Localize
                      "Closing Anitemp"),
                  content: Text(
                      // TODO: Localize
                      "Do you really want to close Anitemp? All unsaved data will be lost."),
                  actions: <TextButton>[
                    TextButton(
                        onPressed: () => Navigator.pop<bool>(context, true),
                        child: Text(
                            // TODO: Localize
                            "Yes",
                            style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.red[700]
                                    : Colors.redAccent))),
                    TextButton(
                        onPressed: () => Navigator.pop<bool>(context, false),
                        child: Text(
                            // TODO: Localize
                            "No"))
                  ])) ??
      false;
}

class _CloseConfirmScaffoldDesktopState extends _CloseConfirmScaffoldBaseState {
  static bool _initedCloseHandler = false;

  @override
  void initState() {
    super.initState();
    if (!_initedCloseHandler) {
      FlutterWindowClose.setWindowShouldCloseHandler(requestClose);
      _initedCloseHandler = true;
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: widget._scaffold);
}

class _CloseConfirmScaffoldPortableState
    extends _CloseConfirmScaffoldBaseState {
  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: requestClose, child: SafeArea(child: widget._scaffold));
}
