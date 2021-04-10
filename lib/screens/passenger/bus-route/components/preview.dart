import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

class PreviewScreen extends StatefulWidget {
  LatLng origin;
  LatLng destination;
  LatLng closestPointFromDestination;
  LatLng closestPointFromOrigin;
  List<LatLng> routes;

  PreviewScreen({
    Key key,
    @required this.origin,
    @required this.destination,
    @required this.closestPointFromOrigin,
    @required this.closestPointFromDestination,
    @required this.routes,
  }) : super(key: key);

  @override
  _PreviewScreenState createState() => _PreviewScreenState(this.origin, this.destination, this.closestPointFromOrigin, this.closestPointFromDestination, this.routes);
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
  
  _PreviewScreenState(
    this.origin,
    this.destination,
    this.closestPointFromOrigin,
    this.closestPointFromDestination,
    this.routes,
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
          markerId: MarkerId('closestPointFromOrigin'),
          position: closestPointFromOrigin,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: InfoWindow(
            title: "Titik Naik"
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    print(origin);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          ''
        ),
      ),
      body: Container(
        child: GoogleMap(
          onMapCreated: _onMapCreated,
          markers: _markers,
          polylines: _polylines,
          initialCameraPosition: CameraPosition(
            target: origin,
            zoom: 15
          ),
          myLocationEnabled: true,
        ),
      ),
    );
  }
}