import 'package:flutter/material.dart';

import '../theme/colour.dart';

abstract class ActionButtons<B extends ButtonStyleButton>
    extends StatelessWidget {
  final EdgeInsetsGeometry btnPadding;
  final TextStyle btnTextStyle;

  ActionButtons(
      {super.key,
      this.btnPadding = const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      this.btnTextStyle = const TextStyle(fontSize: 18)});

  List<B> _btnOptions(BuildContext context);

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

class SaveAndDiscardActionButtons extends ActionButtons<ElevatedButton> {
  final VoidCallback? onSave;
  final VoidCallback? onDiscard;

  SaveAndDiscardActionButtons(
      {super.key,
      required this.onSave,
      required this.onDiscard,
      super.btnPadding,
      super.btnTextStyle});

  @override
  List<ElevatedButton> _btnOptions(BuildContext context) => <ElevatedButton>[
        ElevatedButton(
            onPressed: onSave,
            child: Padding(
                padding: btnPadding,
                child: Text(
                    // TODO: Localize
                    "Save",
                    style: btnTextStyle)),
            style: ButtonStyle(
                backgroundColor:
                    AnitempThemeColourHandler(context).mspSuccess)),
        ElevatedButton(
            onPressed: onDiscard,
            child: Padding(
                padding: btnPadding,
                child: Text(
                    // TODO: Localize
                    "Discard",
                    style: btnTextStyle)),
            style: ButtonStyle(
                backgroundColor: AnitempThemeColourHandler(context).mspError))
      ];
}
