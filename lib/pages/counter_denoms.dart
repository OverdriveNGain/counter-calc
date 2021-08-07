import 'package:flutter/material.dart';
import 'package:calc/scripts/theme.dart';
import 'package:calc/scripts/func.dart';
import 'package:flutter/services.dart';
import 'package:calc/scripts/save.dart';

class CounterDenominations extends StatefulWidget {
  @override
  _CounterDenominationsState createState() => _CounterDenominationsState();
}

class _CounterDenominationsState extends State<CounterDenominations> {
  List<Denomination> denominations;

  void backToHome() async {
    Save.denominations = denominations;
    await Save.saveDenominations();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> restoreConfirm() async{
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Restore default values?"),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            },
              child: Text("No", style: TextStyle( color: Themes.accent)),
            ),
            TextButton(onPressed: () {
              denominations = Denomination.defaultDenom;
              Navigator.pop(context);
              setState((){});
            },
              child: Text("Yes", style: TextStyle( color: Themes.accent)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
     denominations ??= Save.denominations.map((i) {return i.copy();}).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit denominations"),
        backgroundColor: Themes.accent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Confirm Changes?"),
                  // content: Text("Save changes?"),
                  actions:[
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                    },
                      child: Text("Back", style: TextStyle( color: Themes.accent)),
                    ),
                    TextButton(onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                      child: Text("Revert", style: TextStyle( color: Themes.accent)),
                    ),
                    TextButton(onPressed: () {
                      backToHome();
                    },
                      child: Text("Save", style: TextStyle( color: Themes.accent)),
                    ),
                  ],
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                restoreConfirm();
                },
              icon: Icon(Icons.restore))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Themes.accent,
        onPressed: () {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              TextEditingController tec = TextEditingController();
              return AlertDialog(
                title: Text("Enter new value:"),
                content:TextFormField(
                  controller: tec,
                ),
                actions:[
                  TextButton(onPressed: () {
                    Navigator.pop(context);
                  },
                    child: Text("Cancel", style: TextStyle( color: Themes.accent)),
                  ),
                  TextButton(onPressed: () {
                    print("value is " + tec.text.toString());
                    double f = double.parse(tec.text.toString());
                    setState(() {
                      denominations.add(Denomination(f));
                    });
                    Navigator.pop(context);
                  },
                    child: Text("Confirm", style: TextStyle( color: Themes.accent)),
                  ),
                ],
              );
            },
          );
        },
      ),
      body: Container(
        color:Themes.secondary,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ReorderableListView(
            header: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                  "Drag to reorder",
                  style: TextStyle(
                    fontSize: 15,
                    color:Themes.words,
                  ),
              )
            ),
            onReorder: (i, j) {
              Denomination k = denominations[i];
              denominations.removeAt(i);
              int newIndex = i < j?j - 1:j;
              denominations.insert(newIndex, k);

              setState(() { });
            },
            children: List.generate(denominations.length, (i) {
                return Card(
                  elevation:3.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  key:ValueKey(denominations[i].value),
                  child: ListTile(
                    leading: Text(
                      doubleMinimize(denominations[i].value),
                      style: TextStyle(
                        fontSize: 15,
                        color: Themes.words,
                      ),
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.settings, color: Themes.accent),
                      onSelected: (s) {
                        if (s == "remove"){
                          setState((){denominations.removeAt(i);});
                        }
                        else if (s == "change"){
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              TextEditingController tec = TextEditingController();
                              tec.text = doubleMinimize(denominations[i].value) ;
                              return AlertDialog(
                                title: Text("Change existing value:"),
                                content:TextFormField(
                                  controller: tec,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                                actions:[
                                  TextButton(onPressed: () {
                                    Navigator.pop(context);
                                  },
                                    child: Text("Cancel", style: TextStyle( color: Themes.accent)),
                                  ),
                                  TextButton(onPressed: () {
                                    double f = double.parse(tec.text.toString());
                                    setState(() {
                                      denominations[i].value = f;
                                    });
                                    Navigator.pop(context);
                                  },
                                    child: Text("Confirm", style: TextStyle( color: Themes.accent)),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(child: Text("Change"), value: "change"),
                          PopupMenuItem(child: Text("Remove"), value: "remove"),
                        ];
                      },
                    )
                  ),
                );
              })
          ),
        ),
      ),
    );
  }
}
