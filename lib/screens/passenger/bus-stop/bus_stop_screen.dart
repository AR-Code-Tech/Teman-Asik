import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';
import 'package:teman_asik/screens/passenger/bus-stop/components/body.dart';

class BusStopScreen extends StatefulWidget {
  @override
  _BusStopScreenState createState() => _BusStopScreenState();
}

class _BusStopScreenState extends State<BusStopScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: BusStopBody(),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.my_location),
      //   onPressed: () {

      //   },
      // ),
    );
  }
}
