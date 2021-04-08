import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:teman_asik/constans.dart';
import 'package:http/http.dart' as http;
import '../../../constans.dart';
import '../../../constans.dart';
import '../../../constans.dart';
import '../../../constans.dart';
import 'models/route.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
    });
    _getRoute();
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

  @override
  Widget build(BuildContext context) {
    final BusListDetailScreenArguments args = ModalRoute.of(context).settings.arguments;
    final routeTitle = 'Rute Lyn ${args.id.toUpperCase()}';
    final routeDescription = 'Trmn. Gub. Suryo -- Nyai Ageng Pinatih -- Basuki Rahmat -- Pahlawan -- Veteran -- Trmn. Gulomantung -- (PP)';
    setState(() {
      routeArgs = args;
    });
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
                initialChildSize: .35,
                minChildSize: 0.15,
                maxChildSize: .5,
                // maxChildSize: 0.8,
                builder: (BuildContext c, s) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
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
                            height: 8,
                            width: 50,
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
                                IconButton(
                                  icon: Icon(Icons.chevron_left),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  highlightColor: kPrimaryColor,
                                  focusColor: kPrimaryColor,
                                  splashColor: kPrimaryColor,
                                ),
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
          ],
        )
      ),
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   crossAxisAlignment: CrossAxisAlignment.end,
      //   children: [
      //     FloatingActionButton.extended(
      //       heroTag: '1',
      //       onPressed: _locateRoute,
      //       label: Text('Lihat Rute'),
      //       icon: Icon(Icons.alt_route),
      //       backgroundColor: Colors.green,
      //     ),
      //     SizedBox(height: 10),
      //     FloatingActionButton.extended(
      //         heroTag: '2',
      //         onPressed: _locatePosition,
      //         label: Text('Lokasi Saya'),
      //         icon: Icon(Icons.gps_fixed)),
      //   ],
      // ),
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
