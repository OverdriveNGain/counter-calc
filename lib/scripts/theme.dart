import 'package:flutter/material.dart';

enum themeMode {Default, Dark}
class Themes{
  static Color primary;
  static Color secondary;
  static Color accent;
  static Color words;

  static void setTheme(themeMode tm){
    switch (tm){
      case themeMode.Default:
        primary = Colors.white;
        secondary = Colors.grey[300];
        accent = Colors.red;
        words = Colors.black;
        break;
      case themeMode.Dark:
        primary = Colors.grey[900];
        secondary = Colors.grey[800];
        accent = Colors.orange[700];
        words = Colors.white;
        break;
    }
  }
}