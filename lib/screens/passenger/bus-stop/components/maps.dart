import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:teman_asik/constans.dart';

// ignore: must_be_immutable
class BusStopMaps extends StatelessWidget {
  GoogleMapController _googleMapController;
  final LatLng latLng;
  final String busStopName;

  BusStopMaps({
    Key key,
    @required this.latLng,
    @required this.busStopName,
  }) : super(key: key);



  void _onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;
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
        CameraPosition(target: latLng, zoom: 15)));
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
                markers: {
                  Marker(
                    markerId: MarkerId(busStopName),
                    position: latLng,
                    infoWindow: InfoWindow(title: busStopName),
                    icon: BitmapDescriptor.defaultMarker,
                  ),
                },
                initialCameraPosition: CameraPosition(
                  target: latLng,
                  zoom: 17,
                ),
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
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
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: '1',
            onPressed: _locateRoute,
            label: Text('Fokus Halte'),
            icon: Icon(Icons.alt_route),
            backgroundColor: Colors.green,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: '2',
            onPressed: _locatePosition,
            label: Text('Lokasi Saya'),
            icon: Icon(Icons.gps_fixed)
          ),
        ],
      ),
    );
  }
}
