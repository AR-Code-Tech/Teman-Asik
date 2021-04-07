import 'screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'screens/passenger/home/home_screen.dart';
import 'screens/passenger/bus-list-detail/bus_list_detail_screen.dart';
import 'screens/test.dart';

final Map<String, Widget Function(BuildContext)> routes = {
  '/': (ctx)  => HomeScreen(),
  '/passenger/home': (ctx)  => PassengerHomeScreen(),
  '/passenger/bus-list-detail': (ctx)  => BusListDetailScreen(),
  '/test': (ctx) => TestScreen()
};