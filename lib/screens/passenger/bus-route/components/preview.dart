import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teman_asik/constans.dart';
import 'bus_route_body.dart';

class RouteModel {
  double lat;
  double lng;
  String name;

  RouteModel({
    @required this.lat,
    @required this.lng,
    @required this.name,
  });
}

// ignore: must_be_immutable
class PreviewScreen extends StatefulWidget {
  LatLng origin;
  LatLng destination;
  LatLng closestPointFromDestination;
  LatLng closestPointFromOrigin;
  List<LatLng> routes;
  CarModel car;

  PreviewScreen({
    Key key,
    @required this.origin,
    @required this.destination,
    @required this.closestPointFromOrigin,
    @required this.closestPointFromDestination,
    @required this.routes,
    @required this.car,
  }) : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState(
    this.origin,
    this.destination,
    this.closestPointFromOrigin,
    this.closestPointFromDestination,
    this.routes,
    this.car
  );
}

class _PreviewScreenState extends State<PreviewScreen> {
  GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> routes;
  LatLng origin;
  LatLng destination;
  LatLng closestPointFromOrigin;
  LatLng closestPointFromDestination;
  CarModel car;
  
  _PreviewScreenState(
    this.origin,
    this.destination,
    this.closestPointFromOrigin,
    this.closestPointFromDestination,
    this.routes,
    this.car,
  );

  @override
  void initState() {
    super.initState();
    setState(() {
      var p = Polyline(
        polylineId: PolylineId('rute'),
        visible: true,
        points: List.from(routes),
        color: Colors.blue,
        width: 4
      );
      _polylines.add(p);

      LatLng sourceLocation = closestPointFromOrigin;
      LatLng destLocation = closestPointFromDestination;
      LatLng temp;
      if (sourceLocation.latitude > destLocation.latitude) {
        temp = sourceLocation;
        sourceLocation = destLocation;
        destLocation = temp;
      }
    });


    _getLineOrigin();
    _getLineDestination();
  }

  void _getLineDestination() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      kGoogleApiKey,
      PointLatLng(destination.latitude, destination.longitude),
      PointLatLng(closestPointFromDestination.latitude, closestPointFromDestination.longitude),
      travelMode: TravelMode.walking
    );
    List<LatLng> routeTravel = [];
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng pos) {
        routeTravel.add(LatLng(pos.latitude, pos.longitude));
      });
    }
    var p2 = Polyline(
      polylineId: PolylineId('rute-destination'),
      visible: true,
      points: List.from(routeTravel),
      color: Colors.orange,
      width: 4
    );
    setState(() {
      _polylines.add(p2);
    });
  }

  void _getLineOrigin() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      kGoogleApiKey,
      PointLatLng(origin.latitude, origin.longitude),
      PointLatLng(closestPointFromOrigin.latitude, closestPointFromOrigin.longitude),
      travelMode: TravelMode.walking
    );
    List<LatLng> routeTravel = [];
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng pos) {
        routeTravel.add(LatLng(pos.latitude, pos.longitude));
      });
    }
    var p2 = Polyline(
      polylineId: PolylineId('rute-origin'),
      visible: true,
      points: List.from(routeTravel),
      color: Colors.orange,
      width: 4
    );
    setState(() {
      _polylines.add(p2);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
      _markers.add(
        Marker(
          markerId: MarkerId('origin'),
          position: origin,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)
        )
      );
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
          markerId: MarkerId('closestPointFromDestination'),
          position: closestPointFromDestination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: "Titik Kamu Turun"
          ),
        )
      );
    });


    // 
    LatLng sourceLocation = origin;
    LatLng destLocation = destination;
    LatLng temp;
    if (sourceLocation.latitude > destLocation.latitude) {
      temp = sourceLocation;
      sourceLocation = destLocation;
      destLocation = temp;
    }
    LatLngBounds bound = LatLngBounds(southwest: sourceLocation, northeast: destLocation);
    CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
    controller.animateCamera(u2).then((void v) {
      check(u2, controller);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
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
                ],
              ),
            ),
          ],
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: '1',
            onPressed: () async {
              if (await confirm(
                context,
                title: Text('Konfirmasi'),
                content: Text('Apakah kamu yakin ingin memulai navigasi?'),
                textOK: Text('Ya'),
                textCancel: Text('Tidak'),
              )) {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('navigation', true);
                await prefs.setInt('navigation_step', 1);
                await prefs.setInt('navigation_transportation', car.id);
                await prefs.setDouble('navigation_destination_latitude', destination.latitude);
                await prefs.setDouble('navigation_destination_longitude', destination.longitude);
                Navigator.pop(context);
                return Navigator.pushReplacementNamed(context, '/passenger/live-navigation');
              }
            },
            label: Text('Mulai Navigasi'),
            icon: Icon(Icons.navigation),
            backgroundColor: kPrimaryColor,
          ),
          // SizedBox(height: 10),
        ],
      ),
    );
  }
}