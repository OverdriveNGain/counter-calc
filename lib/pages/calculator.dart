import 'package:flutter/material.dart';
import 'package:calc/scripts/theme.dart';
import 'package:calc/scripts/func.dart';
import 'package:flutter/services.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:calc/scripts/save.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CalcSta{
  static final int maxStack = 50;

  static Parser p = Parser();
  static String seq = "";
  static ContextModel cm = ContextModel();
  static List<String> dispStack = List.generate(maxStack, (index) => "");
  static int dispStackI = 0;
  static int dispStackUpdatedUpToI = 0; // inclusive
}

class Calc extends StatefulWidget {
  @override
  _CalcState createState() => _CalcState();
}

class _CalcState extends State<Calc> {
  String multiplyFormat(String exp){
    String temp = "";
    for (int i = 0; i < exp.length - 1; i++){
      if (exp[i] == ")" && "1234567890.(".contains(exp[i+1])){
        temp += ")*";
      }
      else if ("1234567890.)".contains(exp[i]) && exp[i+1] == "("){
        temp += exp[i] + "*";
      }
      else{
        temp += exp[i];
      }
    }
    temp += exp[exp.length - 1];
    return temp;
  }

  void updateScreen([bool refresh = true]){

    String last = CalcSta.seq[CalcSta.seq.length - 1];
    if (last == "C")
      CalcSta.seq = "";
    else if (last == "~")
      CalcSta.seq = Save.calcDisp.length == 0?"":Save.calcDisp.substring(0, Save.calcDisp.length - 1);
    else if (CalcSta.seq[CalcSta.seq.length - 1] == "="){
      CalcSta.seq = CalcSta.seq.substring(0, CalcSta.seq.length - 1);
      CalcSta.seq = multiplyFormat(CalcSta.seq);
      try{
        double v = (CalcSta.p.parse(CalcSta.seq).evaluate(EvaluationType.REAL, CalcSta.cm) as double);
        if ((v < 0?-v:v) > 9000000000000)
          CalcSta.seq = "error";
        else{
          if (v == v.truncateToDouble())
            CalcSta.seq = v.truncate().toString();
          else
            CalcSta.seq = doubleMinimize(double.parse(v.toStringAsFixed(12)));
        }
      }
      catch(e){
        CalcSta.seq = "error";
      }
    }

    if (CalcSta.seq == "error")
      setState(() {
        Save.calcDisp = "Error";
        CalcSta.seq = "";
      });
    else
      setState(() {
        Save.calcDisp = CalcSta.seq;
      });

    if (CalcSta.dispStackUpdatedUpToI + 1 == CalcSta.maxStack){ // full stack
      CalcSta.dispStack.removeAt(0);
      CalcSta.dispStack.add(Save.calcDisp);
    }
    else{ // not full stack
      CalcSta.dispStackI++;
      CalcSta.dispStackUpdatedUpToI = CalcSta.dispStackI;
      CalcSta.dispStack[CalcSta.dispStackI] = Save.calcDisp;
    }

    Save.saveCalc();
  }

  Widget GetButton(String addToSeq, {Widget child, String childText, Color buttonColor}){
    if (child != null && childText != null)
      throw Exception("Only one of child and childText should non-null");
    if (child == null && childText == null)
      childText = addToSeq;

    Widget toMakeChild = child == null?
      Text(
        childText,
        style: TextStyle(
          color: Themes
              .words,
          fontSize: 50,
        ),
      ):
      child;

    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
        child: RaisedButton(
          color: buttonColor == null?Themes.primary:buttonColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          elevation:2.0,
          onPressed: (){
            CalcSta.seq += addToSeq;
            updateScreen();
          },
          child: toMakeChild
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
        backgroundColor: Themes.accent,
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: (CalcSta.dispStackI == 0)? null: () {
              setState(() {
                CalcSta.dispStackI--;
                String disp = CalcSta.dispStack[CalcSta.dispStackI];
                Save.calcDisp = disp;
                CalcSta.seq = disp;
                setState((){});
              });},
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: (CalcSta.dispStackI == CalcSta.dispStackUpdatedUpToI)? null: () {
              setState(() {
                CalcSta.dispStackI++;
                String disp = CalcSta.dispStack[CalcSta.dispStackI];
                Save.calcDisp = disp;
                CalcSta.seq = disp;
                setState((){});
              });}
            ,
          )
        ],
      ),
      body: Container(
        color: Themes.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget> [
            Expanded( // Top Result
              flex: 1,
              child: GestureDetector(
                onLongPress: () {
                  Clipboard.setData(ClipboardData(text: Save.calcDisp));
                  Fluttertoast.showToast(
                      msg: "Value copied to clipboard!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      // backgroundColor: Colors.red,
                      // textColor: Colors.white,
                      fontSize: 16.0
                  );
                },
                child: Container(
                  margin: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: Themes.primary,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: AutoSizeText(
                      Save.calcDisp,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 55,
                      ),
                      maxFontSize: 55,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget> [
                    Expanded( // row 2
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          GetButton("7"),
                          GetButton("8"),
                          GetButton("9"),
                          GetButton("C"),
                        ],
                      ),
                    ),
                    Expanded( // row 3
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          GetButton("4"),
                          GetButton("5"),
                          GetButton("6"),
                          GetButton("*"),
                        ],
                      ),
                    ),
                    Expanded( // row 4
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          GetButton("1"),
                          GetButton("2"),
                          GetButton("3"),
                          GetButton("/"),
                        ],
                      ),
                    ),
                    Expanded( // row 5
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          GetButton("."),
                          GetButton("0"),
                          GetButton("+"),
                          GetButton("-"),
                        ],
                      ),
                    ),
                    Expanded( // row 5
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          GetButton("("),
                          GetButton(")"),
                          GetButton("~", child: Icon(Icons.backspace, color: Themes.words, size: 35)),
                          GetButton(
                            "=",
                            buttonColor: Themes.accent,
                            child: Text(
                              "=",
                              style: TextStyle(
                                color: Themes.primary,
                                fontSize: 50,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ]
                ),
              ),
            ),
          ],
        ),
      )
    );
  }
}
