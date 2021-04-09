import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

class PassengerMapBody extends StatefulWidget {
  @override
  _PassengerMapBodyState createState() => _PassengerMapBodyState();
}

class _PassengerMapBodyState extends State<PassengerMapBody> {
  GoogleMapController _googleMapController;
  LatLng myPos = LatLng(0, 0);

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
    });
    _locatePosition();
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

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: myPos,
        zoom: 15,
      ),
      myLocationEnabled: true,
    );
  }
}
