import 'dart:ui';

import 'package:flutter/material.dart';

int substringCount(String s, String sub){
  int counter = 0;
  for (int i = 0; i < s.length - sub.length + 1; i++)
    if (sub == (s.substring(i, i + sub.length))){
      counter++;
    }
  return counter;
}

bool parenthesisCheck(String s){
  String stack = "";
  for (int i = 0; i < s.length; i++){
    if (s[i] == "(")
      stack = "(" + stack;
    else if (s[i] == ")"){
      if (stack.length > 0 && stack[0] == "(")
        stack = stack.substring(1);
      else
        return false;
    }
  }
  return (stack.length == 0);
}

String doubleMinimize(double d){
  if (d == d.toInt())
    return d.toInt().toString();
  String stringD = d.toString();
  if (stringD[stringD.length - 1] != "0")
    return stringD;
  for (int i = stringD.length - 1; i >= 0; i--){
    if (stringD[i] != "0")
      return stringD.substring(0, i);
  }
  return stringD;
}

Color lighten(Color c, double norm){
  return Color.fromARGB(
      c.alpha,
      lerpDouble(c.red, 255, norm).floor(),
      lerpDouble(c.green, 255, norm).floor(),
      lerpDouble(c.blue, 255, norm).floor());
}