import 'package:flutter/material.dart';
import 'package:calc/scripts/func.dart';
import 'package:flutter/services.dart';
import 'package:calc/scripts/save.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Count extends StatefulWidget {
  @override
  _Count createState() => _Count();
}

String displayTotal(List<Denomination> denoms){
  double temp = 0;
  for (int i = 0; i < denoms.length; i++){
    temp += denoms[i].getSumValue();
  }
  return doubleMinimize(temp);
}

class _Count extends State<Count> {
  List<TextEditingController> denominationControllers;

  void clearConfirmationDialog() {
    var d =  AlertDialog(
        title: Text("Reset?"),
        content: Text("Reset all fields?"),
        actions: [
          TextButton(
            child: Text("No"),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text("Yes"),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                for (int i = 0; i < Save.denominations.length; i++){
                  Save.denominations[i].count = 0;
                  textControllersRefresh(i);
                }
              });
            },
          ),
        ]);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => d,
    ).then((x) {return x;});
  }
  void textControllersRefresh(int i){
    int count = Save.denominations[i].count;
    denominationControllers[i].text = count != 0?count.toString():"";
  }

  @override
  Widget build(BuildContext context){
    if (denominationControllers == null){
      denominationControllers = List.generate(Save.denominations.length, (n) { return TextEditingController();});
      for (int i = 0; i < Save.denominations.length; i++){
        textControllersRefresh(i);
      }
    }

    ColorScheme cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Counter"),
        actions: [
          IconButton(
            onPressed: (){
              FocusScope.of(context).unfocus();
              clearConfirmationDialog();
            },
            icon: Icon(Icons.replay_sharp),
            tooltip: "Clear all",
          ),
          // PopupMenuButton<String>(
          PopupMenuButton<String>(
            onSelected: (s) async {
              if (s == "denominations"){
                await Navigator.pushNamed(context, "/counter_denoms");
                setState(() { });
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Edit denominations"),
                value: "denominations",
              ),
            ],
          ),
        ],
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: displayTotal(Save.denominations)));
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
                    alignment: Alignment.center,
                    decoration:BoxDecoration(
                      // borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: cs.surface
                    ),
                    child: Text(
                      displayTotal(Save.denominations),
                      style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(8.0, 0, 8,8),
                child: SingleChildScrollView(
                  // itemCount: Save.denominations.length,
                  child: Column(children: List.generate(Save.denominations.length, (i) => Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                        elevation:2.0,
                        child: Container(
                          // padding: EdgeInsets.symmetric(vertical:2.0, horizontal:12.0),
                          padding: EdgeInsets.fromLTRB(30, 2, 12, 2),
                          child: Row(
                            children: <Widget> [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  doubleMinimize(Save.denominations[i].value),
                                  style: TextStyle(
                                    fontSize: 15
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex:3,
                                      child: Container(
                                        margin: EdgeInsets.all(5.0),
                                        child: TextFormField(
                                          cursorColor: Theme.of(context).colorScheme.primary,
                                          controller: denominationControllers[i],
                                          maxLines: 1,
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          textInputAction: TextInputAction.next,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.grey[100],
                                            border: OutlineInputBorder(borderSide: BorderSide.none)
                                          ),
                                          onChanged: (s){
                                            setState(() {
                                              Save.denominations[i].count = int.parse(s);
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex:3,
                                      child: Text(
                                        doubleMinimize(Save.denominations[i].getSumValue()).toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.replay_sharp, color: cs.primary),
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        setState(() {
                                          FocusScope.of(context).unfocus();
                                          Save.denominations[i].count = 0;
                                          textControllersRefresh(i);
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.remove_circle, color: cs.primary),
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        setState(() {
                                          FocusScope.of(context).unfocus();
                                          if (Save.denominations[i].count > 0) {
                                            Save.denominations[i].count--;
                                            textControllersRefresh(i);
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.add_circle, color: cs.primary),
                                      padding: EdgeInsets.all(0.0),
                                      onPressed: () {
                                        setState(() {
                                          FocusScope.of(context).unfocus();
                                          Save.denominations[i].count++;
                                          textControllersRefresh(i);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                    )
                  ).toList()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
