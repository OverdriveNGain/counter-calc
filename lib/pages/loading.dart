import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:calc/scripts/theme.dart';
import 'package:calc/scripts/save.dart';

class Loading extends StatelessWidget {
  void loadData(BuildContext context) async{
    await Save.loadDenominations();
    await Save.loadScreenI();
    await Save.loadCalc();
    Navigator.pushReplacementNamed(context, "/home");
  }

  @override
  Widget build(BuildContext context) {
    loadData(context);

    return Container(
      color: Themes.accent,
      child: SpinKitRotatingCircle(
        color: Colors.white,
      ),
    );
  }
}
