import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teman_asik/constans.dart';
// import 'package:location/location.dart';

class PassengerMapBody extends StatefulWidget {
  @override
  _PassengerMapBodyState createState() => _PassengerMapBodyState();
}

class _PassengerMapBodyState extends State<PassengerMapBody> {
  GoogleMapController _googleMapController;
  LatLng myPos = LatLng(0, 0);
  int passengerPrediction = 0;

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
    final maxWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Align(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: myPos,
              zoom: 15,
            ),
            myLocationEnabled: true,
          ),
        ),
        SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: kDefaultPadding,
                left: kDefaultPadding * 2,
                child: SizedBox(
                  width: maxWidth - (kDefaultPadding * 4),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Text(
                        'Calon Penumpang : $passengerPrediction',
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
        ),
      ],
    );
  }
}
