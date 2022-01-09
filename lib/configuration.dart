import 'package:flutter/material.dart';
import 'package:emoney/models/EMoneyModel.dart';

class Configuration extends InheritedWidget{
  Configuration({
    Key key,
    Widget child,
  }) : super(key: key, child: child);

//  String ip_public_alt = "203.142.77.243";
  String ip_public = "203.142.77.243";
  String ip_port = "80" ;
  String serverName = "EMoney";
  String apkName = "EMoney";
  String apkVersion = "1.0";
  String getMessage = "";

  String get baseUrl => "http://"+ip_public+"/"+serverName;
//  String get baseUrlAlt => "http://"+ip_public_alt+":"+ip_port+"/"+serverName;

  String initRoute = "";

  bool updateShouldNotify(oldWidget) => true;

  static Configuration of(BuildContext context) {
    Configuration configuration = context.dependOnInheritedWidgetOfExactType<Configuration>();
    return configuration;
  }
}

final config = Configuration();