import 'package:flutter/material.dart';
import 'package:test0/model/constant.dart';

class MyAppTheme with ChangeNotifier{
  bool darkMode = false;
  MaterialColor? color = Colors.blue;

  ThemeData currentTheme (){
    return ThemeData(
      brightness: darkMode? Brightness.dark : Brightness.light,
      primaryColor: color,
      primarySwatch: color,
    );
  }

  void switchBrightness(){
    darkMode = darkMode? false : true;
    notifyListeners();
  }

  void setBrightness(bool value){
    darkMode = value;
    notifyListeners();
  }

  void setColor(String value){
    color = Constant.colorOptions[value];
    notifyListeners();
  }


}