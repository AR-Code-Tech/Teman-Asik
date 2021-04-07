import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';
import 'package:http/http.dart' as http;
import 'models/route.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';

class BusListDetailScreenArguments {
  final String id;
  BusListDetailScreenArguments(this.id);
}

class BusListDetailScreen extends StatefulWidget {
  @override
  _BusListDetailScreenState createState() => _BusListDetailScreenState();
}

class _BusListDetailScreenState extends State<BusListDetailScreen> {
  GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng centerPos;
  BusListDetailScreenArguments routeArgs;

  @override
  void initState() {
    super.initState();
    // _calculateRoute();
  }

  void _onMapCreated (GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
    });
    _getRoute();
  }
  
  void _locatePosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17
          )
        )
      );
    });
  }

  void _locateRoute() {
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: centerPos,
          zoom: 17
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final BusListDetailScreenArguments args = ModalRoute.of(context).settings.arguments;
    setState(() {
      routeArgs = args;
    });
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        color: kBackgroundColor,
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          markers: _markers,
          polylines: _polylines,
          initialCameraPosition: CameraPosition(
            target: LatLng(0, 0),
            zoom: 15
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
      ),
      appBar: AppBar(
        title: Text('Rute Lync ${args.id.toUpperCase()}'),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: '1',
            onPressed: _locateRoute,
            label: Text('Lihat Rute'),
            icon: Icon(Icons.alt_route),
            backgroundColor: Colors.green,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: '2',
            onPressed: _locatePosition,
            label: Text('Lokasi Saya'),
            icon: Icon(Icons.gps_fixed)
          ),
        ],
      ),
    );
  }
  
  Future<List<RouteModel>> _getRoute() async {
    var url = Uri.parse('http://68.183.227.243:3001/routes?rute=Rute%20Lyn%20${routeArgs.id.toUpperCase()}');
    var httpResult = await http.get(url);
    var data = json.decode(httpResult.body);
    List<RouteModel> routes = [];
    List<LatLng> routesLatLngList = [];
    for(var route in data) {
      var rute = RouteModel(lat: route["lat"], lng: route["lng"], name: route["nama"]);
      routes.add(rute);
      routesLatLngList.add(LatLng(route["lat"], route["lng"]));
    }

    setState(() {
      var p = Polyline(
        polylineId: PolylineId('rute'),
        visible: true,
        points: List.from(routesLatLngList),
        color: Colors.blue,
        width: 4
      );
      _polylines.add(p);
      centerPos = (routesLatLngList.length > 0) ? routesLatLngList.first : LatLng(0, 0);
    });

    _locateRoute();

    return routes;
  }

  Future _calculateRoute() async {
    PointLatLng start = PointLatLng(-7.151893264394567, 112.64947727055232);
    PointLatLng end = PointLatLng(-7.153357653887202, 112.65425746239123);
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "AIzaSyDiCInoDZEAuZeLRme9jZphpsN4KsHWenQ",
      start,
      end
    );
    print(result.errorMessage);
  }
}
