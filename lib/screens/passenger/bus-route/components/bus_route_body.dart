import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class BusRouteBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          markers: {
            Marker(
              markerId: MarkerId("asd"),
              position: LatLng(-7.522284, 112.413506),
              infoWindow: InfoWindow(title: "asd"),
              icon: BitmapDescriptor.defaultMarker,
            ),
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(-7.522284, 112.413506),
            zoom: 17,
          ),
        ),
      ],
    );
  }
}
