import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';
import 'package:http/http.dart' as http;
import '../../../constans.dart';
import 'models/route.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class BusListDetailScreenArguments {
  final int id;
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
  LatLng centerPos = LatLng(0, 0);
  BusListDetailScreenArguments routeArgs;
  bool isLoading = true;
  String routeTitle = "";
  String routeDescription = "";
  int cint = 1;

  @override
  void initState() {
    super.initState();
    // _calculateRoute();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
    });
  }

  void _locatePosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 17)));
    });
  }

  void _locateRoute() {
    _googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: centerPos, zoom: 15)));
  }

  void _getDetail(int id) async {
    List<RouteModel> routes = [];

    try {
      var url = Uri.parse('$apiUrl/transportations/$id');
      var httpResult = await http.get(url);
      var body = json.decode(httpResult.body);
      var data = body["data"];

      // 
      setState(() {
        routeTitle = data["name"];
        routeDescription = data["description"];
      });

      // route list
      // print(data["routes"]);
      List<LatLng> routesLatLngList = [];
      for (var route in data["routes"]) {
        try {
          var rute = RouteModel(lat: route["latitude"], lng: route["longitude"], name: "");
          routes.add(rute);
          routesLatLngList.add(LatLng(route["latitude"], route["longitude"]));
        } catch (e) {
        }
      }
      print(routesLatLngList.length);
      setState(() {
        var p = Polyline(
            polylineId: PolylineId('rute'),
            visible: true,
            points: List.from(routesLatLngList),
            color: Colors.blue,
            width: 4);
        _polylines.add(p);
        
        centerPos = (routesLatLngList.length > 0) 
          ? routesLatLngList.first
          : LatLng(0, 0);
      });

      setState(() {
        isLoading = false;
      });
      Timer(Duration(milliseconds: 500), () => _locateRoute());
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final BusListDetailScreenArguments args = ModalRoute.of(context).settings.arguments;
    setState(() {
      routeArgs = args;
    });
    if (cint == 1) {
      _getDetail(args.id);
      cint++;
    }
    if (isLoading) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: Container(
          color: kBackgroundColor,
          child: Center(
            child: Text(
              'Loading...'
            ),
          ),
        )
      );
    }
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Container(
        color: kBackgroundColor,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                markers: _markers,
                polylines: _polylines,
                initialCameraPosition: CameraPosition(target: LatLng(0, 0), zoom: 15),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),
            SizedBox.expand(
              child: DraggableScrollableSheet(
                initialChildSize: .3,
                minChildSize: 0.15,
                maxChildSize: .5,
                // maxChildSize: 0.8,
                builder: (BuildContext c, s) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 10.0,
                          )
                        ]),
                    child: ListView(
                      controller: s,
                      children: <Widget>[
                        Center(
                          child: Container(
                            height: 5,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  routeTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              routeDescription
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _locatePosition,
                                  label: Text('Lokasi Saya'),
                                  icon: Icon(Icons.gps_fixed)
                                ),
                                SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: _locateRoute,
                                  label: Text('Lihat Rute'),
                                  icon: Icon(Icons.alt_route),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: kDefaultPadding,
                    left: 0,
                    child: RawMaterialButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      elevation: 5.0,
                      fillColor: kBackgroundColor,
                      child: Icon(
                        Icons.chevron_left,
                        size: 24.0,
                        color: kDarkColor,
                      ),
                      padding: EdgeInsets.all(5.0),
                      shape: CircleBorder(),
                    ),
                  ),
                  Positioned(
                    top: kDefaultPadding,
                    right: 0,
                    child: RawMaterialButton(
                      onPressed: () {
                        _locatePosition();
                      },
                      elevation: 5.0,
                      fillColor: kBackgroundColor,
                      child: Icon(
                        Icons.gps_fixed,
                        size: 16.0,
                        color: kDarkColor,
                      ),
                      padding: EdgeInsets.all(5.0),
                      shape: CircleBorder(),
                    ),
                  ),
                ],
              ),
            )
          ],
        )
      ),
    );
  }

  Future<List<RouteModel>> _getRoute() async {
    List<RouteModel> routes = [];
    
    try {
      var url = Uri.parse('http://68.183.227.243:3001/routes?rute=Rute%20Lyn%20A');
      var httpResult = await http.get(url);
      var data = json.decode(httpResult.body);
      List<LatLng> routesLatLngList = [];
      for (var route in data) {
        var rute =
            RouteModel(lat: route["lat"], lng: route["lng"], name: route["nama"]);
        routes.add(rute);
        routesLatLngList.add(LatLng(route["lat"], route["lng"]));
      }

      setState(() {
        var p = Polyline(
            polylineId: PolylineId('rute'),
            visible: true,
            points: List.from(routesLatLngList),
            color: Colors.blue,
            width: 4);
        _polylines.add(p);
        
        centerPos = (routesLatLngList.length > 0) 
          ? routesLatLngList.first
          : LatLng(0, 0);
      });

      _locateRoute();
    } catch (e) {
      print(e);
    }

    return routes;
  }
}
