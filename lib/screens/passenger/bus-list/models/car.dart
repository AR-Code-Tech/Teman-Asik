import 'package:flutter/material.dart';

class CarModel {
  String id;
  String title;
  String description;
  Color iconColor;
  IconData icon;

  CarModel({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.icon,
    @required this.iconColor
  });
}