import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';
import 'package:teman_asik/screens/passenger/bus-route/bus_route_screen.dart';
import 'package:teman_asik/screens/passenger/bus-stop/bus_stop_screen.dart';
import 'package:teman_asik/screens/passenger/bus-list/bus_list_screen.dart';

class PassengerHomeScreen extends StatefulWidget {
  @override
  _PassengerHomeScreenState createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  int _selectedIndex = 0;
  BuildContext context;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    BusListScreen(),
    BusRouteScreen(),
    BusStopScreen(),
    Text(
      'Faq 2',
      style: optionStyle,
    ),
    Container(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == _widgetOptions.length-1) Navigator.pushReplacementNamed(this.context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final itemBackgroundColor = Colors.grey[200];
    setState(() {
      this.context = context;
    });
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey[300],
              width: 1
            )
          )
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus),
              label: 'Home',
              backgroundColor: itemBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.alt_route),
              label: 'Pilih Rute',
              backgroundColor: itemBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Halte',
              backgroundColor: itemBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.question_answer),
              label: 'Faq',
              backgroundColor: itemBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.close),
              label: 'Exit',
              backgroundColor: kPrimaryColor,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: kPrimaryColor,
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: false,
          showSelectedLabels: false,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
