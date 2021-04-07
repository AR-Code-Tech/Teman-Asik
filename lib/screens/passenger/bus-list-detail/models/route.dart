import 'package:flutter/material.dart';

class RouteModel {
  double lat;
  double lng;
  String name;

  RouteModel({
    @required this.lat,
    @required this.lng,
    @required this.name,
  });
}