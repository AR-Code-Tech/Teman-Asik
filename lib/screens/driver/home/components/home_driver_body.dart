import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asik/constans.dart';
import 'package:teman_asik/screens/driver/home/profile/profile_driver.dart';
import 'package:teman_asik/screens/driver/passengerMaps/passenger_maps_screen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class HomeDriverBody extends StatefulWidget {
  @override
  _HomeDriverBodyState createState() => _HomeDriverBodyState();
}

class _HomeDriverBodyState extends State<HomeDriverBody> {
  IO.Socket socket;
  int _selectedIndex = 0;
  BuildContext context;
  Location _location;
  LatLng myPos = LatLng(0, 0);
  bool isSocketConnected = false;

  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    PassengerMapsScreen(),
    ProfileDriver(),
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

  Future<void> initSocket() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = (prefs.getString('auth_token') ?? '');
      var url = Uri.parse('$apiUrl/auth/profile');
      var httpResult = await http.post(
        url,
        headers: <String, String>{
          'Accept': 'application/json;',
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        }
      );
      var data = json.decode(httpResult.body);
      if (httpResult.statusCode != 200) {
        Navigator.pushReplacementNamed(context, '/');
      }

      socket = IO.io('$socketUrl', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': true,
      });
      socket.onConnect((_) {
        Object info = { 'user_id': data['id'], 'transportation_id': data['role']['transportation']['id'] };
        print('connected to server');
        socket.emit('imadriver', info);
        setState(() {
          isSocketConnected = true;
        });
      });
      socket.onDisconnect((_) => print('disconnected'));
      socket.onConnectError((data) => print(data));
      socket.onConnectTimeout((data) => print(data));
      socket.onError((data) => print(data));
      socket.connect();
    } catch (e) {
      print(e);
    }
  }

  void init() async {
    // 
    await initSocket();

    // location
    _location = new Location();
    LocationData locdat = await _location.getLocation();
    setState(() => myPos = LatLng(locdat.latitude, locdat.longitude));
    onLocationChange(locdat.latitude, locdat.longitude);
    _location.onLocationChanged().listen((LocationData locationdata) async {
      setState(() => myPos = LatLng(locationdata.latitude, locationdata.longitude));
      onLocationChange(locationdata.latitude, locationdata.longitude);
    });
  }

  Future<void> onLocationChange(double latitude, double longitude) async {
    Object data = { 'latitude': latitude, 'longitude': longitude };
    socket.emit('driver:update', data);
    print(data);
  }

  @override
  void dispose() {
    super.dispose();
    socket.disconnect();
  }

  @override
  void initState() {
    super.initState();
    init();
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
