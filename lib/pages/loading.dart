import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.background,
      child: SpinKitRotatingCircle(
        color: cs.primary,
      ),
    );
  }
}
