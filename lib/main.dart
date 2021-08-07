import 'package:flutter/material.dart';
import 'package:calc/pages/calculator.dart';
import 'package:calc/pages/counter.dart';
import 'package:calc/pages/counter_denoms.dart';
import 'package:calc/pages/loading.dart';
import 'package:calc/scripts/save.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData.from(colorScheme: ColorScheme(
      primary: Colors.red,
      primaryVariant: Colors.red[300],
      secondary: Colors.red,
      secondaryVariant: Colors.red[300],
      surface: Colors.white,
      onSurface: Colors.black,
      background: Colors.grey[50],
      onBackground: Colors.black,
      onError: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
      error: Colors.purple
    )),
    routes: {
      "/": (context) => Loading(),
      "/counter_denoms": (context) => CounterDenominations(),
      "/home": (context) => HomePage()
    },
  ));
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pc = PageController();

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((d) {
      pc.animateToPage(
          Save.screenI,
          duration: Duration(milliseconds:1),
          curve: Curves.bounceIn
      );
    });

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        // backgroundColor: Themes.primary,
        // unselectedItemColor: Themes.accent,
        // selectedItemColor: lighten(Themes.accent, 0.75),
        // fixedColor: Themes.accent,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "Counter"),
          BottomNavigationBarItem(icon: Icon(Icons.calculate), label: "Calculator"),
        ],
        currentIndex: Save.screenI,
        onTap: (i) {
          setState(() {
            Save.screenI = i;
            pc.animateToPage(
                i,
                duration: Duration(milliseconds:200),
                curve: Curves.bounceIn
            );
          });
        },
      ),
      body: PageView(
        controller: pc,
        onPageChanged: (i){
          setState(() {
            Save.screenI = i;
            Save.saveScreenI();
          });
        },
        children: <Widget> [
          Center(
            child: Count(),
          ),
          Center(
            child: Calc(),
          )
        ],
      ),
    );
  }
}
