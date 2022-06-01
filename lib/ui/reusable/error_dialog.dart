import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

import '../../archive/error.dart' as errlog;

Future<void> showErrorDialog(
    BuildContext context, Object error, String contextMessage) async {
  DateTime errTime = DateTime.now();

  List<TextButton> btns = <TextButton>[
    TextButton(onPressed: () => Navigator.pop(context), child: Text(
        // TODO: Localize
        "Close")),
  ];

  if (kDebugMode) {
    btns.addAll(<TextButton>[
      TextButton(
          child: Text(
              // TODO: Localize
              "Print error"),
          onPressed: () {
            print(error);
          }),
      TextButton(
          child: Text("Export error to file"),
          onPressed: () => errlog.saveErrorLog(error, errTime))
    ]);
  }

  await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(title: Text(
          // TODO: Localize
          "Error"), content: Text(contextMessage), actions: btns));
}
