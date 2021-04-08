import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusStopMaps extends StatelessWidget {
  final LatLng latLng;
  final String busStopName;
  BusStopMaps({
    Key key,
    @required this.latLng,
    @required this.busStopName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
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
      ),
    );
  }
}
