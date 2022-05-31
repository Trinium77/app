import 'package:flutter/material.dart';

/// Like [AppBar] but [Colors.transparent] preference.
class TransperantAppBar extends AppBar {
  TransperantAppBar(
      {super.key,
      super.actions,
      super.actionsIconTheme,
      super.automaticallyImplyLeading,
      super.backwardsCompatibility,
      super.bottom,
      super.bottomOpacity,
      super.brightness,
      super.excludeHeaderSemantics,
      super.flexibleSpace,
      super.foregroundColor,
      super.iconTheme,
      super.leading,
      super.leadingWidth,
      super.primary,
      super.scrolledUnderElevation,
      super.shadowColor,
      super.shape,
      super.surfaceTintColor,
      super.systemOverlayStyle,
      super.toolbarHeight,
      super.toolbarOpacity,
      super.toolbarTextStyle})
      : super(elevation: 0, backgroundColor: Colors.transparent);

  factory TransperantAppBar.unifyIconTheme(BuildContext context,
          {Key? key, Color? light = Colors.black, Color? dark}) =>
      TransperantAppBar(
          key: key,
          iconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.light
                  ? light
                  : dark));
}
