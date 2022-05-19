import 'package:flutter/material.dart';

class LabeledDivider extends Divider {
  final String label;
  final TextStyle labelTextStyle;
  final EdgeInsetsGeometry labelPadding;

  const LabeledDivider(
      {Key? key,
      required this.label,
      this.labelTextStyle =
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
      this.labelPadding = const EdgeInsetsDirectional.fromSTEB(8, 2, 8, 0),
      Color? color,
      double? endIndent,
      double? height,
      double? indent,
      double? thickness})
      : super(
            key: key,
            color: color,
            endIndent: endIndent ?? 8,
            indent: indent ?? 8,
            height: height,
            thickness: thickness);

  @override
  Widget build(BuildContext context) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
                padding: labelPadding,
                child: Text(label, style: labelTextStyle)),
            super.build(context)
          ]);
}
