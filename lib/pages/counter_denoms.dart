import 'package:flutter/material.dart';
import 'package:calc/scripts/theme.dart';
import 'package:calc/scripts/func.dart';
import 'package:flutter/services.dart';
import 'package:calc/scripts/save.dart';

class CounterDenoms extends StatefulWidget {
  @override
  _CounterDenomsState createState() => _CounterDenomsState();
}

class _CounterDenomsState extends State<CounterDenoms> {
  List<Denomination> denoms;

  void backToHome() async {
    Save.denominations = denoms;
    await Save.saveDenominations();
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<void> RestoreConfirm() async{
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        TextEditingController tec = TextEditingController();
        return AlertDialog(
          title: Text("Restore default values?"),
          // content: TextFormField(
          //   controller: tec,
          // ),
          actions: [
            FlatButton(onPressed: () {
              Navigator.pop(context);
            },
              child: Text("No", style: TextStyle( color: Themes.accent)),
            ),
            FlatButton(onPressed: () {
              denoms = Denomination.defaultDenom;
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
     denoms ??= Save.denominations.map((i) {return i.copy();}).toList();

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
                    FlatButton(onPressed: () {
                      Navigator.pop(context);
                    },
                      child: Text("Back", style: TextStyle( color: Themes.accent)),
                    ),
                    FlatButton(onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                      child: Text("Revert", style: TextStyle( color: Themes.accent)),
                    ),
                    FlatButton(onPressed: () {
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
                RestoreConfirm();
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
                  FlatButton(onPressed: () {
                    Navigator.pop(context);
                  },
                    child: Text("Cancel", style: TextStyle( color: Themes.accent)),
                  ),
                  FlatButton(onPressed: () {
                    print("value is " + tec.text.toString());
                    double f = double.parse(tec.text.toString());
                    setState(() {
                      denoms.add(Denomination(f));
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
              Denomination k = denoms[i];
              denoms.removeAt(i);
              int newIndex = i < j?j - 1:j;
              denoms.insert(newIndex, k);

              setState(() { });
            },
            children: List.generate(denoms.length, (i) {
                return Card(
                  elevation:3.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
                  key:ValueKey(denoms[i].value),
                  child: ListTile(
                    leading: Text(
                      doubleMinimize(denoms[i].value),
                      style: TextStyle(
                        fontSize: 15,
                        color: Themes.words,
                      ),
                    ),
                    trailing: PopupMenuButton(
                      icon: Icon(Icons.settings, color: Themes.accent),
                      onSelected: (s) {
                        if (s == "remove"){
                          setState((){denoms.removeAt(i);});
                        }
                        else if (s == "change"){
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              TextEditingController tec = TextEditingController();
                              tec.text = doubleMinimize(denoms[i].value) ;
                              return AlertDialog(
                                title: Text("Change existing value:"),
                                content:TextFormField(
                                  controller: tec,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                ),
                                actions:[
                                  FlatButton(onPressed: () {
                                    Navigator.pop(context);
                                  },
                                    child: Text("Cancel", style: TextStyle( color: Themes.accent)),
                                  ),
                                  FlatButton(onPressed: () {
                                    double f = double.parse(tec.text.toString());
                                    setState(() {
                                      denoms[i].value = f;
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
