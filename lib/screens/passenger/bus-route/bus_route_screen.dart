import 'package:flutter/material.dart';
import 'package:teman_asik/screens/passenger/bus-route/components/bus_route_body.dart';

class BusRouteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BusRouteBody(),
    );
  }
}

final List<double> lat = <double>[
    -7.522284,
    -7.463156,
  ];
  final List<double> lng = <double>[
    112.413506,
    112.431951,
  ];