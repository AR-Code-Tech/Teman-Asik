import 'package:flutter/material.dart';
import 'constans.dart';
import 'screens/home/home_screen.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Montserrat'),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
