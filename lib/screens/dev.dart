import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:teman_asik/constans.dart';

class Driver {
  int userId;
  int transportationId;
  LatLng position;

  Driver({
    @required this.userId,
    @required this.transportationId,
    @required this.position,
  });
}

class DevScreen extends StatefulWidget {
  @override
  _DevScreenState createState() => _DevScreenState();
}

class _DevScreenState extends State<DevScreen> {
  IO.Socket socket;
  GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  List<Driver> drivers = [];
  List<Object> passengers = [];
  Timer timerUpdateDriverMarker;

  void updateDriverMarker() async {
    setState(() {
      _markers.clear();
      for (Driver driver in drivers) {
        _markers.add(Marker(
          markerId: MarkerId('driver-${driver.userId}'),
          position: driver.position,
          infoWindow: InfoWindow(
            title: 'Driver ${driver.userId} - Id transportation : ${driver.transportationId}'
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        ));
      }
    });
  }

  void initSocket() {
    socket = IO.io('$socketUrl', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.onConnect((_) {
      print('Connected to server');
    });
    socket.on('drivers', (data) {
      drivers.clear();
      for(var item in data) {
        try {
          drivers.add(Driver(
            userId: item['user_id'],
            transportationId: item['transportation_id'],
            position: LatLng(item['location']['latitude'], item['location']['longitude']),
          ));
        } catch (e) {
        }
      }
    });
    socket.on('passengers', (data) {
      passengers.clear();
      for(var item in data) {
        try {
          passengers.add({
            'userId': item['user_id'],
            'transportationId': item['transportation_id'],
            // 'position': LatLng(item['location']['latitude'], item['location']['longitude']),
          });
        } catch (e) {
        }
      }
    });
    socket.onDisconnect((_) => print('disconnected'));
    socket.onConnectError((data) => print(data));
    socket.onConnectTimeout((data) => print(data));
    socket.onError((data) => print(data));
    socket.connect();
  }

  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _googleMapController = controller;
    });
  }
  
  @override
  void initState() {
    super.initState();
    initSocket();
    timerUpdateDriverMarker = Timer.periodic(Duration(seconds: 1), (timer) {
      updateDriverMarker();
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.close();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: GoogleMap(
          markers: _markers,
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(0.0, 112.0),
            zoom: 3
          ),
        ),
      ),
    );
  }
}