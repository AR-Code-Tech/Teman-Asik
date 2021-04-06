import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';
import 'package:teman_asik/screens/passenger/bus-list/components/body.dart';

class BusListScreen extends StatefulWidget {
  @override
  _BusListScreenState createState() => _BusListScreenState();
}

class _BusListScreenState extends State<BusListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: BusListBody(),
    );
  }
}
