import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:teman_asik/constans.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:location/location.dart';
import '../../home/components/home_driver_body.dart';

class PassengerMapBody extends StatefulWidget {
  @override
  _PassengerMapBodyState createState() => _PassengerMapBodyState();
}

class _PassengerMapBodyState extends State<PassengerMapBody> {
  GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  LatLng myPos = LatLng(0, 0);
  int passengerPrediction = 0;
  Timer a;

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
              zoom: 0)));
    });
  }

  void init() {
  }

  @override
  void dispose() {
    super.dispose();
    a.cancel();
  }

  @override
  void initState() {
    super.initState();
    init();
    a = Timer.periodic(Duration(seconds: 1), (timer) {
      updateMarker();
    });
  }

  void updateMarker() {
    for(Driver driver in Drivers.data) {
      setState(() {
        _markers.add(Marker(
          markerId: MarkerId('driver-${driver.userId}'),
          position: driver.position
        ));
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        Align(
          child: GoogleMap(
            onMapCreated: _onMapCreated,
            markers: _markers,
            initialCameraPosition: CameraPosition(
              target: myPos,
              zoom: 2,
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
