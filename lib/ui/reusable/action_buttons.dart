import 'package:flutter/material.dart';

import '../theme/colour.dart';

mixin TwoOptionsActionButtons<B extends ButtonStyleButton> on ActionButtons<B> {
  VoidCallback? get _accept;
  VoidCallback? get _discard;

  String _acceptTxt(BuildContext context);
  String _discardTxt(BuildContext context);
}

mixin TextButtonBasedTwoOptionsActionButtons
    on ActionButtons<TextButton>, TwoOptionsActionButtons<TextButton> {
  @override
  List<TextButton> _btnOptions(BuildContext context) => <TextButton>[
        TextButton(
            onPressed: _accept,
            child: _btnTextWrapper(Text(_acceptTxt(context),
                style: btnTextStyle.copyWith(
                    color: AnitempThemeColourHandler(context).success)))),
        TextButton(
            onPressed: _discard,
            child: _btnTextWrapper(Text(_discardTxt(context),
                style: btnTextStyle.copyWith(
                    color: AnitempThemeColourHandler(context).error))))
      ];
}

mixin ElevatedButtonBasedTwoOptionsActionButtons
    on ActionButtons<ElevatedButton>, TwoOptionsActionButtons<ElevatedButton> {
  @override
  List<ElevatedButton> _btnOptions(BuildContext context) => <ElevatedButton>[
        ElevatedButton(
            onPressed: _accept,
            child:
                _btnTextWrapper(Text(_acceptTxt(context), style: btnTextStyle)),
            style: ButtonStyle(
                backgroundColor:
                    AnitempThemeColourHandler(context).mspSuccess)),
        ElevatedButton(
            onPressed: _discard,
            child: _btnTextWrapper(
                Text(_discardTxt(context), style: btnTextStyle)),
            style: ButtonStyle(
                backgroundColor: AnitempThemeColourHandler(context).mspError))
      ];
}

abstract class ActionButtons<B extends ButtonStyleButton>
    extends StatelessWidget {
  final EdgeInsetsGeometry btnPadding;
  final TextStyle btnTextStyle;

  ActionButtons(
      {super.key,
      this.btnPadding = const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      this.btnTextStyle = const TextStyle(fontSize: 18)});

  List<B> _btnOptions(BuildContext context);

  Padding _btnTextWrapper(Text txt) => Padding(padding: btnPadding, child: txt);

  @override
  Widget build(BuildContext context) {
    List<B> opts = _btnOptions(context);

    assert(opts.length >= 2 && opts.length <= 3);

    return LayoutBuilder(
        builder: (context, constraints) => Flex(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            direction:
                constraints.maxWidth >= 720 ? Axis.horizontal : Axis.vertical,
            children: opts
                .map((btn) =>
                    Padding(padding: const EdgeInsets.all(10), child: btn))
                .toList()));
  }
}

class SaveAndDiscardActionButtons extends ActionButtons<ElevatedButton>
    with TwoOptionsActionButtons, ElevatedButtonBasedTwoOptionsActionButtons {
  final VoidCallback? onSave;
  final VoidCallback? onDiscard;

  SaveAndDiscardActionButtons(
      {super.key,
      required this.onSave,
      required this.onDiscard,
      super.btnPadding,
      super.btnTextStyle});

  @override
  VoidCallback? get _accept => onSave;

  @override
  String _acceptTxt(BuildContext context) {
    return "Save";
  }

  @override
  VoidCallback? get _discard => onDiscard;

  @override
  String _discardTxt(BuildContext context) {
    return "Discard";
  }
}

abstract class YesAndNoActionButtons<B extends ButtonStyleButton>
    implements ActionButtons<B> {
  VoidCallback? get onYes;
  VoidCallback? get onNo;

  static YesAndNoActionButtons<TextButton> textButton(
          {Key? key,
          required VoidCallback? onYes,
          required VoidCallback? onNo,
          EdgeInsetsGeometry btnPadding =
              const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          TextStyle btnTextStyle = const TextStyle(fontSize: 18)}) =>
      _YesAndNoTextActionButtons(
          key: key,
          onYes: onYes,
          onNo: onNo,
          btnPadding: btnPadding,
          btnTextStyle: btnTextStyle);

  static YesAndNoActionButtons<ElevatedButton> elevatedButton(
          {Key? key,
          required VoidCallback? onYes,
          required VoidCallback? onNo,
          EdgeInsetsGeometry btnPadding =
              const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          TextStyle btnTextStyle = const TextStyle(fontSize: 18)}) =>
      _YesAndNoElevatedActionButtons(
          key: key,
          onYes: onYes,
          onNo: onNo,
          btnPadding: btnPadding,
          btnTextStyle: btnTextStyle);
}

abstract class _YesAndNoActionButtonsBase<B extends ButtonStyleButton>
    extends ActionButtons<B>
    with TwoOptionsActionButtons<B>
    implements YesAndNoActionButtons<B> {
  @override
  final VoidCallback? onNo;

  @override
  final VoidCallback? onYes;

  _YesAndNoActionButtonsBase(
      {super.key,
      required this.onYes,
      required this.onNo,
      super.btnPadding,
      super.btnTextStyle});

  @override
  VoidCallback? get _accept => onYes;

  @override
  String _acceptTxt(BuildContext context) {
    return "Yes";
  }

  @override
  VoidCallback? get _discard => onNo;

  @override
  String _discardTxt(BuildContext context) {
    return "No";
  }
}

class _YesAndNoTextActionButtons extends _YesAndNoActionButtonsBase<TextButton>
    with TextButtonBasedTwoOptionsActionButtons {
  _YesAndNoTextActionButtons(
      {super.key,
      required super.onYes,
      required super.onNo,
      super.btnPadding,
      super.btnTextStyle});
}

class _YesAndNoElevatedActionButtons
    extends _YesAndNoActionButtonsBase<ElevatedButton>
    with ElevatedButtonBasedTwoOptionsActionButtons {
  _YesAndNoElevatedActionButtons(
      {super.key,
      required super.onYes,
      required super.onNo,
      super.btnPadding,
      super.btnTextStyle});
}
