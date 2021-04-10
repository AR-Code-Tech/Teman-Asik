import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_place/google_place.dart';
import 'package:teman_asik/screens/passenger/bus-route/components/search_place.dart';
import '../../../../constans.dart';
import 'bus_route_body.dart';

class SelectLocationScreen extends StatefulWidget {
  @override
  _SelectLocationScreenState createState() => _SelectLocationScreenState();
}

class _SelectLocationScreenState extends State<SelectLocationScreen> {
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);
  GoogleMapController _googleMapController;
  Set<Marker> _markers = {};
  LatLng myPos = LatLng(0, 0);
  LatLng destinationPos;

  @override
  void initState() {
    super.initState();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _googleMapController = controller;
    });
    _locatePosition();
  }

  void _onMapTap(LatLng pos) {
    setState(() {
      if (destinationPos != null) {
        destinationPos = null;
        _markers.removeWhere((marker) => marker.markerId.value == 'destination');
      }
      _addDestination(pos);
    });
  }

  void _addDestination (LatLng pos) {
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('destination'),
          position: pos,
          icon: BitmapDescriptor.defaultMarker
        )
      );
      destinationPos = pos;
    });
  }

  void _focusCameraMap(LatLng position, double zoom) {
    setState(() {
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: zoom
          )
        )
      );
    });
  }

  void _locatePosition() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        LatLng pos = LatLng(position.latitude, position.longitude);
        _focusCameraMap(pos, 17);
        myPos = pos;
      });
    });
  }

  void _searchLocation() async {
    final LatLng result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPlace()
      )
    );
    if (result != null) {
      _addDestination(result);
      _focusCameraMap(
        result,
        17
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Tujuan'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                onTap: _onMapTap,
                markers: _markers,
                initialCameraPosition: CameraPosition(
                  target: LatLng(0.0, 0.0),
                ),
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
              ),
            ),
          ],
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: '1',
            onPressed: _locatePosition,
            label: Text('Lokasi Saya'),
            icon: Icon(Icons.gps_fixed)
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: '2',
            onPressed: _searchLocation,
            label: Text('Cari Lokasi'),
            icon: Icon(Icons.search),
            backgroundColor: Colors.amber,
          ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: '3',
            onPressed: () {
              LocationSelectData data = LocationSelectData(
                origin: myPos,
                destination: destinationPos
              );
              Navigator.pop(context, data);
            },
            label: Text('Pilih'),
            icon: Icon(Icons.check),
            backgroundColor: Colors.green,
          ),
        ],
      ),
    );
  }
}