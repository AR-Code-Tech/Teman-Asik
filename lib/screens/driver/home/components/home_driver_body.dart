import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asik/constans.dart';
import 'package:teman_asik/screens/driver/passengerMaps/passenger_maps_screen.dart';

class HomeDriverBody extends StatefulWidget {
  @override
  _HomeDriverBodyState createState() => _HomeDriverBodyState();
}

class _HomeDriverBodyState extends State<HomeDriverBody> {
  int _selectedIndex = 0;
  BuildContext context;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    PassengerMapsScreen(),
    Text(
      'Faq 2',
      style: optionStyle,
    ),
    Text(
      'Faq 3',
      style: optionStyle,
    ),
    Container(),
  ];

  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    if (index == _widgetOptions.length - 1) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('auth_token', '');
      Navigator.pushReplacementNamed(this.context, '/');
    }
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
            border: Border(top: BorderSide(color: Colors.grey[300], width: 1))),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.hail),
              label: 'Home',
              backgroundColor: itemBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.badge),
              label: 'Pilih Rute',
              backgroundColor: itemBackgroundColor,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_help),
              label: 'Halte',
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
