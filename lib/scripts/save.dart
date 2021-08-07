import 'package:shared_preferences/shared_preferences.dart';

class Denomination{
  static final List<Denomination> defaultDenom = <Denomination> [
    Denomination(1000),
    Denomination(500),
    Denomination(200),
    Denomination(100),
    Denomination(50),
    Denomination(20),
    Denomination(10),
    Denomination(5),
    Denomination(1),
    Denomination(0.25),
  ];

  double value;
  int count;

  Denomination(double value, [count = 0]){
    this.value = value;
    this.count = count;
  }

  double getSumValue(){
    return value * count;
  }

  String toSaveFormatSingle(){
    return "${value.toString()}~$count";
  }
  Denomination copy(){
    return Denomination(value, count);
  }
  static String toSaveFormat(List<Denomination> denoms){
    return denoms.map((d) => "${d.toSaveFormatSingle()}").join("/");
  }
  static List<Denomination> fromSaveFormat(String s){
    List<String> nowSplit = s.split("/");
    List<Denomination> toReturn = [];
    for (String denom in nowSplit) {
      List<String> denumSub = denom.split("~");
      double val = double.parse(denumSub[0]);
      int count = int.parse(denumSub[1]);
      toReturn.add(Denomination(val, count));
    }
    return toReturn;
  }
}

class Save{
  static SharedPreferences _sp;
  static get sp async {
    if (_sp == null){
      var temp = await SharedPreferences.getInstance();
      _sp = temp;
    }
    return _sp;
  }
  static List<Denomination> denominations;
  static String calcDisp;
  static int screenI;

  static Future<void> loadDenominations() async{
    try{
      SharedPreferences _sp = await sp;
      String saved = _sp.getString("denoms");
      denominations = saved == null?Denomination.defaultDenom:Denomination.fromSaveFormat(_sp.getString("denoms"));
    }
    catch (e){
      denominations = Denomination.defaultDenom;
    }
  }
  static Future<void> saveDenominations() async{
    String stringToSave = Denomination.toSaveFormat(denominations);
    SharedPreferences _sp = await sp;
    _sp.setString("denoms", stringToSave);
  }
  static Future<void> loadCalc() async{
    try{
      SharedPreferences _sp = await sp;
      calcDisp = _sp.getString("calc") ?? "";
      print("calcDisp is $calcDisp");
    }
    catch (e){
      calcDisp = "";
    }
  }
  static Future<void> saveCalc() async{
    String stringToSave = calcDisp;
    SharedPreferences _sp = await sp;
    _sp.setString("calc", stringToSave);
  }
  static Future<void> loadScreenI() async{
    try{
      SharedPreferences _sp = await sp;
      screenI = _sp.getInt("screenI") ?? 0;
      print("success getting screenI at $screenI");
    }
    catch (e){
      screenI = 0;
    }
  }
  static Future<void> saveScreenI() async{
    SharedPreferences _sp = await sp;
    _sp.setInt("screenI", screenI);
    print("saved screenI at $screenI");
  }

  static void autosave() async{
    while (true){
      await Future.delayed(Duration(seconds:10));
      await saveDenominations();
      await saveCalc();
      print("saved");
    }
  }
}