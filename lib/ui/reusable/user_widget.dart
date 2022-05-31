import 'package:flutter/material.dart';

import '../../model/user.dart';

mixin UserWidget<U extends User> on Widget {
  U get user;
}
