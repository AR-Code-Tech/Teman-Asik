import 'package:teman_asik/screens/driver/home/home_driver.dart';
import 'package:teman_asik/screens/passenger/bus-route/bus_route_screen.dart';
import 'package:teman_asik/screens/passenger/live-navigation/live_navigation_screen.dart';

import 'screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'screens/passenger/home/home_screen.dart';
import 'screens/passenger/bus-list-detail/bus_list_detail_screen.dart';
import 'screens/driver/login/login_driver.dart';
import 'screens/test.dart';

final Map<String, Widget Function(BuildContext)> routes = {
  '/': (ctx)  => HomeScreen(),
  '/passenger/home': (ctx)  => PassengerHomeScreen(),
  '/passenger/bus-list-detail': (ctx)  => BusListDetailScreen(),
  '/passenger/bus-route': (ctx)  => BusRouteScreen(),
  '/passenger/live-navigation': (ctx)  => LiveNavigationScreen(),
  '/driver/login': (ctx)  => LoginDriver(),
  '/driver/Home': (ctx)  => HomeDriverScreen(),
  '/test': (ctx) => TestScreen()
};