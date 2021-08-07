import 'package:flutter/material.dart';
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
  static List<String> displayStack = List.generate(maxStack, (index) => "");
  static int displayStackInteger = 0;
  static int displayStackUpdatedUpToI = 0; // inclusive
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

    if (CalcSta.displayStackUpdatedUpToI + 1 == CalcSta.maxStack){ // full stack
      CalcSta.displayStack.removeAt(0);
      CalcSta.displayStack.add(Save.calcDisp);
    }
    else{ // not full stack
      CalcSta.displayStackInteger++;
      CalcSta.displayStackUpdatedUpToI = CalcSta.displayStackInteger;
      CalcSta.displayStack[CalcSta.displayStackInteger] = Save.calcDisp;
    }

    Save.saveCalc();
  }

  Widget getButton(String addToSeq, Color buttonColor, {Widget child, String childText}){
    if (child != null && childText != null)
      throw Exception("Only one of child and childText should non-null");
    if (child == null && childText == null)
      childText = addToSeq;

    Widget toMakeChild = child == null?
      Text(
        childText,
        style: TextStyle(
          fontSize: 50,
          color: Colors.black
        ),
      ):
      child;

    return Expanded(
      child: Container(
        margin: EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 0.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: buttonColor,
          ),
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

    final cs = Theme.of(context).colorScheme;
    final normalButtonColor = Colors.white;
    final equalsButtonColor = cs.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text("Calculator"),
        // backgroundColor: Themes.accent,
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: (CalcSta.displayStackInteger == 0)? null: () {
              setState(() {
                CalcSta.displayStackInteger--;
                String display = CalcSta.displayStack[CalcSta.displayStackInteger];
                Save.calcDisp = display;
                CalcSta.seq = display;
                setState((){});
              });},
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: (CalcSta.displayStackInteger == CalcSta.displayStackUpdatedUpToI)? null: () {
              setState(() {
                CalcSta.displayStackInteger++;
                String display = CalcSta.displayStack[CalcSta.displayStackInteger];
                Save.calcDisp = display;
                CalcSta.seq = display;
                setState((){});
              });}
            ,
          )
        ],
      ),
      body: Container(
        // color: Themes.secondary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget> [
            Container( // Top Result
              height:100,
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
                      color: Colors.white,
                      // borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: AutoSizeText(
                      Save.calcDisp.replaceAll("*", "×").replaceAll("/", "÷"),
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
                          getButton("7", normalButtonColor),
                          getButton("8", normalButtonColor),
                          getButton("9", normalButtonColor),
                          getButton("C", normalButtonColor),
                        ],
                      ),
                    ),
                    Expanded( // row 3
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          getButton("4", normalButtonColor),
                          getButton("5", normalButtonColor),
                          getButton("6", normalButtonColor),
                          getButton("*", normalButtonColor, childText:"×"),
                        ],
                      ),
                    ),
                    Expanded( // row 4
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          getButton("1", normalButtonColor),
                          getButton("2", normalButtonColor),
                          getButton("3", normalButtonColor),
                          getButton("/", normalButtonColor, childText:"÷"),
                        ],
                      ),
                    ),
                    Expanded( // row 5
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          getButton(".", normalButtonColor),
                          getButton("0", normalButtonColor),
                          getButton("+", normalButtonColor),
                          getButton("-", normalButtonColor),
                        ],
                      ),
                    ),
                    Expanded( // row 5
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget> [
                          getButton("(", normalButtonColor),
                          getButton(")", normalButtonColor),
                          getButton("~", normalButtonColor, child: Icon(Icons.backspace, size: 35, color: Colors.black)),
                          getButton(
                            "=", equalsButtonColor,
                            // buttonColor: Themes.accent,
                            child: Text(
                              "=",
                              style: TextStyle(
                                color: cs.onPrimary,
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
