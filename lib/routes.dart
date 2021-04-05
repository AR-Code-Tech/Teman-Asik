import 'screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'screens/passenger/home/home_screen.dart';
import 'screens/test.dart';

final Map<String, Widget Function(BuildContext)> routes = {
  '/': (ctx)  => HomeScreen(),
  '/passenger/home': (ctx)  => PassengerHomeScreen(),
  '/test': (ctx) => TestScreen()
};