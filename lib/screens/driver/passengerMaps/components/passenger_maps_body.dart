import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

class PassengerMapBody extends StatefulWidget {
  @override
  _PassengerMapBodyState createState() => _PassengerMapBodyState();
}

class _PassengerMapBodyState extends State<PassengerMapBody> {
  GoogleMapController mapController;
  // Location location = new Location();
  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(-7.463180, 112.431907),
        zoom: 15,
      ),
    );
  }
}
