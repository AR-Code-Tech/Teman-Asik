import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'constans.dart';
import 'routes.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      useDefaultLoading: true,
      child: MaterialApp(
        title: kAppTitle,
        theme: ThemeData(primarySwatch: Colors.blue, fontFamily: kFontFamily),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: routes,
      ),
    );
  }
}
