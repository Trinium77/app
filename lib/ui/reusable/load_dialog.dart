import 'package:flutter/material.dart';

class LoadDialog<T> extends StatefulWidget {
  final Future<T> _future;
  final void Function(Object) _onError;
  final String _loadingLabel;

  LoadDialog._(this._future, this._onError, this._loadingLabel, {super.key});

  static Future<T?> show<T>(BuildContext context,
      {required Future<T> future,
      String loadingLabel = "Loading...",
      void Function(Object)? onError}) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => LoadDialog<T>._(
            future,
            onError ??
                (err) {
                  throw err;
                },
            loadingLabel));
  }

  @override
  State<LoadDialog<T>> createState() => _LoadDialogState();
}

class _LoadDialogState<T> extends State<LoadDialog<T>> {
  late final Future<T> _f;
  late bool _done;

  @override
  void initState() {
    _f = widget._future;
    _done = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async => _done,
      child: FutureBuilder<T>(
          future: _f,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              setState(() {
                _done = true;
              });
              if (snapshot.hasData) {
                Navigator.pop<T>(context, snapshot.data);
              } else if (snapshot.hasError) {
                widget._onError(snapshot.error!);
                Navigator.pop(context);
              }
            }

            return Dialog(
                insetPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox.square(
                          dimension: 28,
                          child: Center(
                              child: Padding(
                                  padding: EdgeInsetsDirectional.only(start: 8),
                                  child: CircularProgressIndicator()))),
                      Text(widget._loadingLabel)
                    ]));
          }));
}
