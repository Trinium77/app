import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/locales.dart';

import '../../model/animal.dart' show Animal;

extension AnimalLocales on Animal {
  String displayName(BuildContext context) {
    switch (this) {
      case Animal.human:
        //return AnitempLocales.of(context).animal_human;
        return "Human";
    }
  }
}
