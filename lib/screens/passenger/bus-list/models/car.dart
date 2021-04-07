import 'package:flutter/material.dart';

class CarModel {
  String id;
  String title;
  Color iconColor;
  IconData icon;

  CarModel({
    @required this.id,
    @required this.title,
    @required this.icon,
    @required this.iconColor
  });
}