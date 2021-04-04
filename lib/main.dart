import 'package:flutter/material.dart';
import 'constans.dart';
import 'screens/home/home_screen.dart';
import 'screens/passenger/bus-stop/bus_stop_screen.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: kFontFamily),
      home: BusStopScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
