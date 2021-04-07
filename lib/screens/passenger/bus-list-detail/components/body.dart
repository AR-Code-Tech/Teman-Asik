import 'package:flutter/material.dart';

class BusListDetailBody extends StatefulWidget {
  @override
  _BusListDetailBodyState createState() => _BusListDetailBodyState();
}

class _BusListDetailBodyState extends State<BusListDetailBody> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Container(
        color: Colors.black,
      ),
      appBar: AppBar(
        title: Text('Child'),
      ),
    );
  }
}