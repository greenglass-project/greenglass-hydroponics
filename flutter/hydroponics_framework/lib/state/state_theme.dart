import 'package:flutter/material.dart';

class StateTheme {
  //static Color inactiveColour = Colors.white24;
  static Color disabledColour = Colors.white24;

  static Color triStateDisabled = Colors.white12;
  static Color triStateOff = Colors.red;
  static Color triStateOn = Colors.green;

  static TextStyle styleForState(TextStyle style, bool? state) {
    if(state == null) {
      return style.copyWith(color: disabledColour);
    } else {
      return style;
    }
  }
  static Icon colourForState(IconData icon, double size, bool?state) {
    return Icon(icon, color: triStateColour(state), size: size);
  }

  static Color triStateColour(bool? state) {
      if(state == null) {
        return triStateDisabled;
  } else if(!state) {
        return triStateOff;
  } else {
        return triStateOn;
      }
  }
}
