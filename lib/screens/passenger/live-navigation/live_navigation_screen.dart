import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asik/constans.dart';
import 'package:wakelock/wakelock.dart';
import '../bus-route/components/body_new.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'dart:math' show cos, sqrt, asin;
import 'package:socket_io_client/socket_io_client.dart' as IO;



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

class Drivers {
  static List<Driver> data = [];
}

class LiveNavigationScreen extends StatefulWidget {
  @override
  _LiveNavigationScreenState createState() => _LiveNavigationScreenState();
}

class _LiveNavigationScreenState extends State<LiveNavigationScreen> {
  IO.Socket socket;
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
  Timer timerUpdateDriverMarker;
  bool isFinished = false;
  List<Driver> oldDriver = [];
  BitmapDescriptor markerUp;
  BitmapDescriptor markerDown;
  BitmapDescriptor markerDestination;
  
  @override
  void initState() {
    super.initState();
    Wakelock.enable();
    setCustomMap();
    init();
  }

  @override
  void dispose() {
    Wakelock.disable();
    timerUpdateDriverMarker.cancel();
    socket.disconnect();
    socket.close();
    socket.dispose();
    super.dispose();
  }


  void setCustomMap() async{
    markerUp = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/icons/naik.png');
    markerDown = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/icons/turun.png');
    markerDestination = await BitmapDescriptor.fromAssetImage(ImageConfiguration(), 'assets/icons/tujuan.png');
  }
  void updateDriverMarker() {
    try {
      List<Driver> tmpDriver = [];
      for(Driver driver in Drivers.data) {
        setState(() {
          for(Driver e in oldDriver) {
            try {
              oldDriver.removeWhere((Driver a) => a.userId == e.userId);
            } catch (e) {
            }
          }
          tmpDriver.add(driver);
          _markers.add(Marker(
            markerId: MarkerId('driver-${driver.userId}'),
            position: driver.position,
            infoWindow: InfoWindow(title: 'Driver - ${driver.transportationId}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ));
        });
      }
      if (oldDriver.length > 0 || tmpDriver.length == 0) {
        setState(() {
          for(Marker marker in _markers) {
            if (marker.markerId.value.toString().toLowerCase().contains('driver-')) {
              _markers.removeWhere((Marker e) => e.markerId.value == marker.markerId.value);
            }
          }
          oldDriver.clear();
          for(Driver driver in tmpDriver) {
            oldDriver.add(driver);
          }
        });
      }
      print('Tmp : ${tmpDriver.length}  Olddriver : ${oldDriver.length}  Drivers : ${Drivers.data.length}');
    } catch (e) {
    }
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
    await _getBusPrediction();
    await _addPositionMarker();
    _focusBound(origin, destination);

    // 
    await onLocationChange();

    // init driver live location
    initSocket();
    timerUpdateDriverMarker = Timer.periodic(Duration(seconds: 1), (timer) {
      updateDriverMarker();
    });
  }

  void initSocket() {
    socket = IO.io('$socketUrl', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.onConnect((_) {
      Object info = { 'transportation_id': navigationTransportation };
      print('Passenger Socket : connected to server');
      socket.emit('imapassenger', info);
    });
    socket.on('drivers', (data) {
      print(data);
      Drivers.data.clear();
      for(var item in data) {
        try {
          Drivers.data.add(Driver(
            userId: item['user_id'],
            transportationId: item['transportation_id'],
            position: LatLng(item['location']['latitude'], item['location']['longitude']),
          ));
        } catch (e) {
        }
      }
      // print('Driver Count : ${Drivers.data.length}');
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
    if (a <= 0.0035 && navigationStep == 1) {
      setState(() => navigationStep++);
    }

    // 
    var b = calculateDistance(origin.latitude, origin.longitude, car.closestPointFromDestination.latitude, car.closestPointFromDestination.longitude);
    if (b <= 0.0105 && navigationStep == 2) {
      setState(() => navigationStep++);
    }

    // 
    var c = calculateDistance(origin.latitude, origin.longitude, destination.latitude, destination.longitude);
    if (c <= 0.0055 && navigationStep == 3) {
      _finishNavigation();
    }

    var pRuteLyn = Polyline(
      polylineId: PolylineId('rute'),
      visible: true,
      points: List.from(car.routes),
      color: Colors.blue,
      width: 4
    );
    if (navigationStep == 1) {
      Polyline p = await drawPolylineBeetween2Point(origin, car.closestPointFromOrigin, 'route-origin', TravelMode.walking);
      setState(() {
        navigationText = 'Silahkan menuju ke titik naik anda untuk menunggu angkutan.';
        _polylines.clear();
        _polylines.add(p);
        _polylines.add(pRuteLyn);
      });
      _focusBound(origin, car.closestPointFromOrigin);
    } else if (navigationStep == 2) {
      setState(() {
        navigationText = 'Silahkan menunggu angkutan di area sekitar anda sekarang. Dan naiklah dan tunggu sampai anda dekat dengan titik turun.';
        _polylines.clear();
        _polylines.add(pRuteLyn);
      });
      _focusBound(car.closestPointFromOrigin, car.closestPointFromDestination);
    } else if (navigationStep == 3) {
      Polyline p = await drawPolylineBeetween2Point(origin, destination, 'route-destination', TravelMode.walking);
      setState(() {
        navigationText = 'Silahkan turun di titik ini dan menuju ke lokasi tujuan anda.';
        _polylines.clear();
        _polylines.add(p);
        _polylines.add(pRuteLyn);
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
    Timer(Duration(milliseconds: 600), () async {
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
    try {
      print(car);
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('destination'),
            position: destination,
            icon: markerDestination,
            infoWindow: InfoWindow(
              title: "Tujuan Kamu"
            ),
          )
        );
        _markers.add(
          Marker(
            markerId: MarkerId('closestPointFromOrigin'),
            position: car.closestPointFromOrigin,
            icon: markerUp,
            infoWindow: InfoWindow(
              title: "Titik Kamu Naik"
            ),
          )
        );
        _markers.add(
          Marker(
            markerId: MarkerId('closestPointFromDestination'),
            position: car.closestPointFromDestination,
            icon: markerDown,
            infoWindow: InfoWindow(
              title: "Titik Kamu Turun"
            ),
          )
        );
      });
    } catch (e) {
      print(e);
    }
  }

  void _exitNavigation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('navigation', false);
    Navigator.pushReplacementNamed(context, '/passenger/home');
  }

  void _finishNavigation() {
    setState(() {
      isFinished = true;
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
    if (isFinished) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        body: SafeArea(
          child: Container(
            color: kBackgroundColor,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius: BorderRadius.circular(99)
                        ),
                        child: Icon(
                          Icons.check,
                          size: 120,
                          color: kLightColor,
                        ),
                      ),
                      SizedBox(height: 30,),
                      Text(
                        'Navigasi Selesai',
                        style: kTitleStyle,
                      ),
                      SizedBox(height: 15,),
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.white),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                          )
                        ),
                        onPressed: _exitNavigation, 
                        child: Row(
                          children: [
                            SizedBox(width: 10,),
                            Text('OK', style: TextStyle(color: kDarkColor),),
                            SizedBox(width: 5,),
                            Icon(Icons.chevron_right, color: kDarkColor,)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
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
            onTap: _exitNavigation,
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
                zoomControlsEnabled: false,
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
                  (navigationStep == 3) ? Positioned(
                    bottom: kDefaultPadding /2,
                    right: kDefaultPadding,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.green),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        )
                      ),
                      onPressed: _finishNavigation,
                      child: Row(
                        children: [
                          Icon(Icons.check),
                          SizedBox(width: 8,),
                          Text('Selesai')
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
              cost: double.parse(item['cost']),
              distance: double.parse(item['distance']),
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
      print(car);
      
    } catch (e) {
      print(e);
    }
    setState(() => isLoading = false);
  }
}