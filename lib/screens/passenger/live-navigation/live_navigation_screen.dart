import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asik/constans.dart';
import 'package:location/location.dart';
import '../bus-route/components/bus_route_body.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show cos, sqrt, asin;


class LiveNavigationScreen extends StatefulWidget {
  @override
  _LiveNavigationScreenState createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {
  GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  LatLng origin = LatLng(0, 0);
  LatLng destination = LatLng(0, 0);
  CarModel car;
  Location _location;
  int navigationStep = 1;
  int navigationTransportation;
  bool isLoading = false;
  String navigationText = '';
  
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double navDestinationLat = (prefs.getDouble('navigation_destination_latitude') ?? 0.0);
    double navDestinationLng = (prefs.getDouble('navigation_destination_longitude') ?? 0.0);
    setState(() {
      navigationStep = (prefs.getInt('navigation_step') ?? 0);
      navigationTransportation = (prefs.getInt('navigation_transportation') ?? 0);
    });
    setState(() {
      destination = LatLng(navDestinationLat, navDestinationLng);
    });

    // location
    _location = new Location();
    await geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.high).then((geo.Position position) {
      setState(() => origin = LatLng(position.latitude, position.longitude));
    });
    _location.onLocationChanged().listen((LocationData locationdata) async {
      setState(() => origin = LatLng(locationdata.latitude, locationdata.longitude));
      await onLocationChange();
    });

    // map
    await _addPositionMarker();
    _focusBound(origin, destination);

    // 
    await onLocationChange();
  }

  void _onMapCreated(GoogleMapController controller) async {
    setState(() {
      _googleMapController = controller;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 - c((lat2 - lat1) * p)/2 + 
          c(lat1 * p) * c(lat2 * p) * 
          (1 - c((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  Future<void> onLocationChange () async {
    if (car == null) return ;

    // -7,151691, 112,65191
    var a = calculateDistance(origin.latitude, origin.longitude, car.closestPointFromOrigin.latitude, car.closestPointFromOrigin.longitude);
    if (a <= 0.0035) {
      if (navigationStep == 1) {
        setState(() => navigationStep++);
      }
    }

    if (navigationStep == 1) {
      Polyline p = await drawPolylineBeetween2Point(origin, car.closestPointFromOrigin, 'route-origin', TravelMode.walking);
      setState(() {
        navigationText = 'Silahkan menuju ke titik naik anda untuk menunggu angkutan.';
        _polylines.clear();
        _polylines.add(p);
      });
      _focusBound(origin, car.closestPointFromOrigin);
    } else if (navigationStep == 2) {
      navigationText = 'Silahkan menunggu angkutan di area sekitar anda sekarang.';
      var p = Polyline(
        polylineId: PolylineId('rute'),
        visible: true,
        points: List.from(car.routes),
        color: Colors.blue,
        width: 4
      );
      setState(() {
        _polylines.clear();
        _polylines.add(p);
      });
      _focusBound(car.closestPointFromOrigin, car.closestPointFromDestination);
    } else if (navigationStep == 3) {
      navigationText = 'Silahkan turun di titik ini dan menuju ke lokasi tujuan anda.';
      Polyline p = await drawPolylineBeetween2Point(origin, destination, 'route-destination', TravelMode.walking);
      setState(() {
        _polylines.clear();
        _polylines.add(p);
      });
      _focusBound(origin, destination);
    }
  }

  Future<Polyline> drawPolylineBeetween2Point(LatLng a, LatLng b, String id, TravelMode tm) async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      kGoogleApiKey,
      PointLatLng(a.latitude, a.longitude),
      PointLatLng(b.latitude, b.longitude),
      travelMode: tm
    );
    List<LatLng> routeTravel = [];
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng pos) {
        routeTravel.add(LatLng(pos.latitude, pos.longitude));
      });
    }
    var p2 = Polyline(
      polylineId: PolylineId(id),
      visible: true,
      points: List.from(routeTravel),
      color: Colors.orange,
      width: 4
    );
    return p2;
  }

  void _focusBound(LatLng sourceLocation, LatLng destLocation) async {
    var t = Timer(Duration(milliseconds: 600), () async {
      LatLng temp;
      if (sourceLocation.latitude > destLocation.latitude) {
        temp = sourceLocation;
        sourceLocation = destLocation;
        destLocation = temp;
      }
      LatLngBounds bound = LatLngBounds(southwest: sourceLocation, northeast: destLocation);
      CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
      _googleMapController.animateCamera(u2).then((void v) async {
        check(u2, _googleMapController);
      });
    });
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    _googleMapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -100 || l2.southwest.latitude == -100) {
      check(u, c);
    }
  }

  Future<void> _addPositionMarker() async {
    await _getBusPrediction();

    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: "Tujuan Kamu"
          ),
        )
      );
      _markers.add(
        Marker(
          markerId: MarkerId('closestPointFromOrigin'),
          position: car.closestPointFromOrigin,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: "Titik Kamu Naik"
          ),
        )
      );
      _markers.add(
        Marker(
          markerId: MarkerId('closestPointFromDestination'),
          position: car.closestPointFromDestination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: "Titik Kamu Turun"
          ),
        )
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
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
      appBar: AppBar(
        backgroundColor: kBackgroundColor,
        title: Text('Navigasi', style: kSubTitleStyle),
        leading: Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('navigation', false);
              Navigator.pushReplacementNamed(context, '/passenger/home');
            },
            child: Icon(
              Icons.close,
              size: 26.0,
              color: Colors.grey[700],
            ),
          )
        ),
      ),
      body: Container(
        color: kBackgroundColor,
        child: Stack(
          children: [
            Align(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                markers: _markers,
                polylines: _polylines,
                initialCameraPosition: CameraPosition(
                  target: origin,
                  zoom: 15
                ),
                zoomControlsEnabled: true,
                compassEnabled: true,
                zoomGesturesEnabled: true,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),
            SafeArea(
              child: Stack(
                children: [
                  (navigationStep != 1) ? Positioned(
                    bottom: kDefaultPadding /2,
                    left: kDefaultPadding,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        )
                      ),
                      onPressed: () async {
                        setState(() => navigationStep--);
                        await onLocationChange();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.chevron_left)
                        ],
                      ),
                    ),
                  ) : Container(),
                  (navigationStep != 3) ? Positioned(
                    bottom: kDefaultPadding /2,
                    right: kDefaultPadding,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        )
                      ),
                      onPressed: () async {
                        setState(() => navigationStep++);
                        await onLocationChange();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.chevron_right)
                        ],
                      ),
                    ),
                  ) : Container(),
                ],
              ),
            ),
            (navigationText != '') ? SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    top: kDefaultPadding,
                    left: kDefaultPadding,
                    child: SizedBox(
                      width: maxWidth - (kDefaultPadding * 2),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: Text(
                            navigationText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: kLightColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ) : Container(),
          ],
        )
      ),
    );
  }
  
  Future<void> _getBusPrediction() async {
    setState(() => isLoading = true);
    try {
      // get bus
      var originUrl = '${origin.latitude},${origin.longitude}';
      var destinationUrl = '${destination.latitude},${destination.longitude}';
      var url = Uri.parse('$apiUrl/navigation?origin=$originUrl&destination=$destinationUrl');
      var httpResult = await http.get(url);
      var data = json.decode(httpResult.body);
      List<CarModel> cars = [];
      int i = 0;
      for(var item in data['transportations']) {
        if (item['id'] == navigationTransportation) {
          List<LatLng> routes = [];
          for (var route in item["routes"]) {
            try {
              var rute = LatLng(route["latitude"], route["longitude"]);
              routes.add(rute);
            } catch (e) {
            }
          }
          setState(() {
            car = CarModel(
              id: item['id'],
              title: item['name'],
              description: item['description'],
              icon: Icons.directions_bus,
              iconColor: Colors.red.withOpacity(0.3),
              routes: routes,
              closestPointFromOrigin: LatLng(item['closestPointFromOrigin']['latitude'], item['closestPointFromOrigin']['longitude']),
              closestPointFromDestination: LatLng(item['closestPointFromDestination']['latitude'], item['closestPointFromDestination']['longitude']),
            );
          });
          break;
        }
      }        
      
    } catch (e) {
      print(e);
    }
    setState(() => isLoading = false);
  }
}