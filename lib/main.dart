import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:teman_asik/screens/home/home_screen.dart';
import 'constans.dart';
import 'routes.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: routes,
    );
  }
}
