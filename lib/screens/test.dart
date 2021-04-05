// AIzaSyDiCInoDZEAuZeLRme9jZphpsN4KsHWenQ
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:teman_asik/constans.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final String apiKey = "AIzaSyDiCInoDZEAuZeLRme9jZphpsN4KsHWenQ";
  GoogleMapController _controller;
  Geolocator geoLocator = Geolocator();
  PolylinePoints polylinePoints;
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};

  List<Marker> _markers = [];
  LatLng currentLocation = LatLng(1.4941728, 115.9022409);
  LatLng destination;
  bool currentPosInited = false;

  _createPolylines(LatLng start, LatLng destination) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      apiKey, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.walking,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        final latitude = point.latitude;
        final longitude = point.longitude;
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        print('CURRENT POS: $latitude $longitude');
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
    final points = result.points;
    print('POS: $points');
  }

  void _locatePosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((Position position) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      _goToTheLake();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = (controller);
      currentPosInited = true;
    });
    _locatePosition();
  }

  void _onMapTap(LatLng position) {
    if (destination == null && currentPosInited == true) {
      setState(() {
        destination = position;
        _markers.add(
          Marker(
            markerId: MarkerId('id-2'),
            position: position,
            infoWindow: InfoWindow(
              title: "Lokasi Tujuan"
            )
          )
        );
      });
    } else {
      setState(() {
        destination = null;
        _markers.removeLast();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _locatePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        onTap: _onMapTap,
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        markers: Set.from(_markers),
        polylines: Set<Polyline>.of(polylines.values),
        initialCameraPosition: CameraPosition(
          target: currentLocation,
          zoom: 5
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          (destination != null) 
           ? FloatingActionButton.extended(
              onPressed: () {
                _createPolylines(currentLocation, destination);
              },
              label: Text('Pilih Rute'),
              icon: Icon(Icons.check),
              backgroundColor: Colors.green,
            )
          : Container(),
          SizedBox(height: 10),
          (destination != null) 
           ? FloatingActionButton.extended(
              onPressed: _goToDestination,
              label: Text('Tujuan'),
              icon: Icon(Icons.location_pin),
              backgroundColor: Colors.red,
            )
          : Container(),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: _locatePosition,
            label: Text('Lokasi Saya'),
            icon: Icon(Icons.gps_fixed)
          ),
        ],
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final CameraPosition _kLake = CameraPosition(
      target: currentLocation,
      zoom: 19
    );
    final GoogleMapController controller = _controller;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }

  Future<void> _goToDestination() async {
    final CameraPosition _kLake = CameraPosition(
      target: destination,
      zoom: 19
    );
    final GoogleMapController controller = _controller;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}