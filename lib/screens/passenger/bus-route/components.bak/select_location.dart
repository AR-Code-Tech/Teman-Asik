import 'dart:async';

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
    _googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: zoom
        )
      )
    );
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
    print(result);
    if (result != null) {
      _addDestination(result);
      setState(() {
        destinationPos = result;
      });

      var t = Timer(Duration(milliseconds: 1200), () {
        // _focusCameraMap(result, 14);
        LatLng sourceLocation = myPos;
        LatLng destLocation = result;
        LatLng temp;
        if (sourceLocation.latitude > destLocation.latitude) {
          temp = sourceLocation;
          sourceLocation = destLocation;
          destLocation = temp;
        }
        LatLngBounds bound = LatLngBounds(southwest: sourceLocation, northeast: destLocation);
        CameraUpdate u2 = CameraUpdate.newLatLngBounds(bound, 50);
        _googleMapController.animateCamera(u2).then((void v) {
          check(u2, _googleMapController);
        });
      });
    }
  }

  void check(CameraUpdate u, GoogleMapController c) async {
    c.animateCamera(u);
    _googleMapController.animateCamera(u);
    LatLngBounds l1 = await c.getVisibleRegion();
    LatLngBounds l2 = await c.getVisibleRegion();

    if (l1.southwest.latitude == -1000 || l2.southwest.latitude == -1000) {
      check(u, c);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Tujuan'),
        actions: [
          GestureDetector(
            onTap: () {
              LocationSelectData data = LocationSelectData(
                origin: myPos,
                destination: destinationPos
              );
              Navigator.pop(context, data);
            },
            child: InkWell(
              splashColor: Colors.white.withOpacity(.30),
              child: Container(
                margin: EdgeInsets.only(right: 10),
                padding: EdgeInsets.all(5),
                child: Icon(Icons.check, size: 30,),
              ),
            ),
          )
        ],
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
            Positioned(
              top: kDefaultPadding,
              right: 0,
              child: RawMaterialButton(
                onPressed: () {
                  _locatePosition();
                },
                elevation: 5.0,
                fillColor: kBackgroundColor,
                child: Icon(
                  Icons.gps_fixed,
                  size: 16.0,
                  color: kDarkColor,
                ),
                padding: EdgeInsets.all(5.0),
                shape: CircleBorder(),
              ),
            ),
          ],
        )
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // FloatingActionButton.extended(
          //   heroTag: '1',
          //   onPressed: _locatePosition,
          //   label: Text('Lokasi Saya'),
          //   icon: Icon(Icons.gps_fixed)
          // ),
          SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: '2',
            onPressed: _searchLocation,
            label: Text('Cari Lokasi'),
            icon: Icon(Icons.search),
            backgroundColor: Colors.amber,
          ),
          // SizedBox(height: 10),
        ],
      ),
    );
  }
}